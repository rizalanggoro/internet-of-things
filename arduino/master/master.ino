#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>

#define LM

#ifdef LM
#include <NTPClient.h>
#include <WiFiUDP.h>
#endif

#define WIFI_SSID "CELOSIA"
#define WIFI_PASS "031298031298"
#define MQTT_BROKER "broker.hivemq.com"
#define MQTT_PORT 1883

#define DEVICE_ID "ESP8266-MATRIX"
#define BASE_TOPIC "com.anggoro.mqtt/"

// topics
String topicMode = "";
String topicBrightness = "";
String topicSpeed = "";
String topicColor = "";

// current states
String currentMode = "0";
String currentBrightness = "100";
String currentSpeed = "1024";
String currentColor = "255.0.100";

WiFiClient espClient;
PubSubClient client(espClient);

// prototipe function
void liveStatus();
void callback(char* topic, byte* payload, unsigned int length);
void reconnect();

void setup() {
  Serial.begin(115200);
  Wire.begin(D1, D2);

  // connect to wifi
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("Connected!");

#ifdef LM
  beginNtp();
#endif

  randomSeed(micros());

  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // setup mqtt
  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(callback);

  // setup topics
  topicMode = String(BASE_TOPIC) + String(DEVICE_ID) + "/mode";
  topicBrightness = String(BASE_TOPIC) + String(DEVICE_ID) + "/brightness";
  topicSpeed = String(BASE_TOPIC) + String(DEVICE_ID) + "/speed";
  topicColor = String(BASE_TOPIC) + String(DEVICE_ID) + "/color";
}

void loop() {
  liveStatus();
  transmitToSlave();

  if (!client.connected()) {
    reconnect();
  }
  client.loop();

#ifdef LM
  streamNtp();
  // sendClockDataToSlave();
#endif
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");

  String receiveData = "";
  for (int i = 0; i < length; i++) {
    receiveData += (char)payload[i];
  }
  Serial.println(receiveData);

  String strTopic = String(topic);
  int in1 = strTopic.lastIndexOf("/");
  String type = strTopic.substring(in1 + 1, in1 + 2);

  if (type == "m") currentMode = receiveData;
  if (type == "b") currentBrightness = receiveData;
  if (type == "s") currentSpeed = receiveData;
  if (type == "c") currentColor = receiveData;
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = String(DEVICE_ID) + "-";
    clientId += String(random(0xffff), HEX);
    // Attempt to connect
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");

      client.subscribe(topicMode.c_str());
      client.subscribe(topicBrightness.c_str());
      client.subscribe(topicSpeed.c_str());
      client.subscribe(topicColor.c_str());
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(2000);
    }
  }
}

unsigned long liveStatusPreviousMillis = 0;
void liveStatus() {
  unsigned long currentMillis = millis();
  if (currentMillis - liveStatusPreviousMillis >= 2000) {
    liveStatusPreviousMillis = currentMillis;

    Serial.print("[");
    Serial.print(currentMillis);
    Serial.print("] HEAP: ");
    Serial.println(ESP.getFreeHeap());
  }
}

unsigned long _transmitToSlavePrevMillis = 0;
void transmitToSlave() {
  unsigned long currentMillis = millis();
  if (currentMillis - _transmitToSlavePrevMillis >= 1000) {
    _transmitToSlavePrevMillis = currentMillis;

    sendI2C("m", currentMode);
    sendI2C("b", currentBrightness);
    sendI2C("s", currentSpeed);
    sendI2C("c", currentColor);

#ifdef LM
    sendI2C("cd", getClockData());
#endif
  }
}

void sendI2C(String type, String data) {
  Wire.beginTransmission(13);
  Wire.write(type.c_str());
  Wire.write(";");
  Wire.write(data.c_str());
  Wire.endTransmission();
}
