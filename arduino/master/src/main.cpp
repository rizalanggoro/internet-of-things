#include <Arduino.h>
#include <ArduinoJson.h>
#include <ESP8266WiFi.h>
#include <LittleFS.h>
#include <PubSubClient.h>

#include "config.hpp"

#ifdef USE_ESP_NOW
#include <espnow.h>
#else
#include <Wire.h>
#endif

#ifdef LM
#include <NTPClient.h>
#include <WiFiUdp.h>
#endif

#ifdef USE_ESP_NOW
typedef struct {
  char key[8];
  char value[16];
} ESPNowMessage;

ESPNowMessage message;
#endif

// prototype functions
void initializeTopics();
void publishDeviceConfig();
void publishFreeHeapAndUptime();
void transmitToSlave();

#ifdef USE_ESP_NOW
void sendESPNow(String type, String data);
void onDataSent(uint8_t* macAddress, uint8_t sendStatus);
#else
void sendI2C(String type, String data);
#endif

void reconnect();
void callback(char* topic, byte* payload, unsigned int length);
void saveFS(const char* path, const String data);
String readFS(const char* path, String defValue);
void saveDeviceConfig();
void readDeviceConfig();

#ifdef LM
String getClockData();
#endif

WiFiClient espClient;
PubSubClient client(espClient);

#ifdef LM
WiFiUDP ntpUdp;
NTPClient ntpClient(ntpUdp, "id.pool.ntp.org", 25200);
#endif

// global variables
bool isWiFiConnected = false;

// topics
// -> sub-topics: flutter to esp
String subTopicAutoMode = "";
String subTopicConfig = "";
String subTopicMode = "";
String subTopicBrightness = "";
String subTopicSpeed = "";
String subTopicColor = "";
String subTopicSave = "";

// -> pub-topics: esp to flutter
String pubTopicUptime = "";
String pubTopicHeap = "";
String pubTopicConfig = "";

// -> current states
String currentMode = "0";
String currentBrightness = "100";
String currentSpeed = "1024";
String currentColor = "255.0.100";
String currentAutoMode = "off";

#define PATH_MODE "/m.txt"
#define PATH_BRIGHTNESS "/b.txt"
#define PATH_SPEED "/s.txt"
#define PATH_COLOR "/c.txt"
#define PATH_AUTO_MODE "/a_m.txt"

uint8_t broadcastAddress[] = {0xE8, 0xDB, 0x84, 0xDA, 0x90, 0x0B};

void setup() {
  Serial.begin(115200);
  delay(2000);

#ifdef USE_ESP_NOW
  WiFi.mode(WIFI_STA);

  if (esp_now_init() != 0) Serial.println("Error initializing ESP-NOW");

  esp_now_set_self_role(ESP_NOW_ROLE_CONTROLLER);
  esp_now_register_send_cb(onDataSent);
  esp_now_add_peer(broadcastAddress, ESP_NOW_ROLE_SLAVE, 1, NULL, 0);
#else
  Wire.begin(SDA_PIN, SCL_PIN);
#endif

#ifdef LM
  ntpClient.begin();
#endif

  Serial.println("Mount LittleFS");
  if (!LittleFS.begin()) {
    Serial.println("LittleFS mount failed");
    return;
  }

  // initialize pin
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);

  initializeTopics();

  // initialize mqtt
  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(callback);

  // begin wifi connection
  WiFi.begin(WIFI_SSID, WIFI_PASS);

  readDeviceConfig();
}

void loop() {
  transmitToSlave();
  publishFreeHeapAndUptime();

#ifdef LM
  ntpClient.update();
#endif

  if (!client.connected()) {
    digitalWrite(LED_BUILTIN, HIGH);
    reconnect();
  }
  client.loop();
}

void initializeTopics() {
  String prefix = String(MQTT_ORG) + "/" + String(MQTT_SECRET) + "/" +
                  String(MQTT_DEVICE_ID);

  // initialize sub-topics
  subTopicConfig = prefix + "/sub/config";
  subTopicMode = prefix + "/sub/mode";
  subTopicBrightness = prefix + "/sub/brightness";
  subTopicSpeed = prefix + "/sub/speed";
  subTopicColor = prefix + "/sub/color";
  subTopicSave = prefix + "/sub/save";
  subTopicAutoMode = prefix + "/sub/auto_mode";

  // initialize pub-topics
  pubTopicUptime = prefix + "/pub/uptime";
  pubTopicHeap = prefix + "/pub/heap";
  pubTopicConfig = prefix + "/pub/config";
}

void callback(char* topic, byte* payload, unsigned int length) {
  String strTopic = String(topic);
  String strPayload = "";

  for (unsigned int a = 0; a < length; a++) strPayload += (char)payload[a];

  Serial.print("[");
  Serial.print(strTopic);
  Serial.print("] ");
  Serial.println(strPayload);

  if (strTopic == subTopicConfig) publishDeviceConfig();
  if (strTopic == subTopicMode) currentMode = strPayload;
  if (strTopic == subTopicBrightness) currentBrightness = strPayload;
  if (strTopic == subTopicSpeed) currentSpeed = strPayload;
  if (strTopic == subTopicColor) currentColor = strPayload;
  if (strTopic == subTopicSave) saveDeviceConfig();
  if (strTopic == subTopicAutoMode) currentAutoMode = strPayload;
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");

    String clientId = String(MQTT_DEVICE_ID) + "-";
    clientId += String(random(0xffff), HEX);

    // Attempt to connect
    if (client.connect(clientId.c_str())) {
      Serial.println("Connected to MQTT.");
      digitalWrite(LED_BUILTIN, LOW);

      // subscribe to all topics
      client.subscribe(subTopicAutoMode.c_str());
      client.subscribe(subTopicBrightness.c_str());
      client.subscribe(subTopicColor.c_str());
      client.subscribe(subTopicConfig.c_str());
      client.subscribe(subTopicMode.c_str());
      client.subscribe(subTopicSave.c_str());
      client.subscribe(subTopicSpeed.c_str());
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 2 seconds");
      delay(2000);
    }
  }
}

void publishDeviceConfig() {
  if (client.connected()) {
    DynamicJsonDocument doc(512);
    doc["mode"] = currentMode;
    doc["brightness"] = currentBrightness;
    doc["speed"] = currentSpeed;
    doc["color"] = currentColor;
    doc["auto_mode"] = currentAutoMode;

    String jsonStr;
    serializeJson(doc, jsonStr);

    client.publish(pubTopicConfig.c_str(), jsonStr.c_str());
  }
}

unsigned long publishFreeHeapAndUptimePrevMillis = 0;
void publishFreeHeapAndUptime() {
  unsigned long currentMillis = millis();
  if (currentMillis - publishFreeHeapAndUptimePrevMillis >= 2000) {
    publishFreeHeapAndUptimePrevMillis = currentMillis;

    if (client.connected()) {
      client.publish(pubTopicHeap.c_str(), String(ESP.getFreeHeap()).c_str());
      client.publish(pubTopicUptime.c_str(), String(millis()).c_str());
    }
  }
}

void saveDeviceConfig() {
  saveFS(PATH_MODE, currentMode);
  saveFS(PATH_BRIGHTNESS, currentBrightness);
  saveFS(PATH_SPEED, currentSpeed);
  saveFS(PATH_COLOR, currentColor);
  saveFS(PATH_AUTO_MODE, currentAutoMode);
}

void readDeviceConfig() {
  currentMode = readFS(PATH_MODE, "0");
  currentBrightness = readFS(PATH_BRIGHTNESS, "100");
  currentSpeed = readFS(PATH_SPEED, "1024");
  currentColor = readFS(PATH_COLOR, "100.0.255");
  currentAutoMode = readFS(PATH_AUTO_MODE, "off");
}

#ifdef LM
String getClockData() {
  String result = "";

  int hour = ntpClient.getHours();
  int minute = ntpClient.getMinutes();
  String h = "";
  String m = "";

  if (hour < 10)
    h = "0" + String(hour);
  else
    h = String(hour);
  if (minute < 10)
    m = "0" + String(minute);
  else
    m = String(minute);

  result = h + m;
  return result;
}
#endif

unsigned long transmitToSlavePrevMillis = 0;
void transmitToSlave() {
  unsigned long currentMillis = millis();
  if (currentMillis - transmitToSlavePrevMillis >= 1000) {
    transmitToSlavePrevMillis = currentMillis;

#ifdef USE_ESP_NOW
    sendESPNow("m", currentMode);
    sendESPNow("b", currentBrightness);
    sendESPNow("s", currentSpeed);
    sendESPNow("c", currentColor);
    sendESPNow("a_m", currentAutoMode);
#else
    sendI2C("m", currentMode);
    sendI2C("b", currentBrightness);
    sendI2C("s", currentSpeed);
    sendI2C("c", currentColor);
    sendI2C("a_m", currentAutoMode);

#ifdef LM
    sendI2C("cd", getClockData());
#endif
#endif
  }
}

#ifdef USE_ESP_NOW
void sendESPNow(String type, String data) {
  strcpy(message.key, type.c_str());
  strcpy(message.value, data.c_str());

  // Send message via ESP-NOW
  esp_now_send(broadcastAddress, (uint8_t*)&message, sizeof(message));
}

void onDataSent(uint8_t* macAddress, uint8_t sendStatus) {
  Serial.print("Last Packet Send Status: ");
  if (sendStatus == 0) {
    Serial.println("Delivery success");
  } else {
    Serial.println("Delivery fail");
  }
}
#else
void sendI2C(String type, String data) {
  Wire.beginTransmission(13);
  Wire.write(type.c_str());
  Wire.write(";");
  Wire.write(data.c_str());
  Wire.endTransmission();
}
#endif

void saveFS(const char* path, const String data) {
  File file = LittleFS.open(path, "w");
  if (!file) {
    Serial.println("Failed to open file for writing");
    return;
  }

  if (file.print(data)) {
    Serial.print("[");
    Serial.print(path);
    Serial.println("] File written");
  } else {
    Serial.println("Write failed");
  }

  file.close();
}

String readFS(const char* path, String defValue) {
  File file = LittleFS.open(path, "r");
  if (!file) {
    Serial.print("[");
    Serial.print(path);
    Serial.println("] Failed to open file for reading");

    return defValue;
  }

  String data = file.readString();
  file.close();

  return data;
}