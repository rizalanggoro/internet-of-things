#include <Arduino.h>
#include <WS2812FX.h>

#include "config.hpp"

#ifdef USE_ESP_NOW
#include <ESP8266WiFi.h>
#include <espnow.h>
#else
#include <Wire.h>
#endif

#ifdef USE_ESP_NOW
typedef struct {
  char key[8];
  char value[16];
} ESPNowMessage;

ESPNowMessage message;
#endif

// prototype functions
#ifdef USE_ESP_NOW
void onDataReceive(uint8_t* mac, uint8_t* incomingData, uint8_t len);
#else
void receiveEvent(int len);
void requestEvent();
#endif
void streamFXOptions();

WS2812FX fx = WS2812FX(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

#ifdef LM
// prototype functions
void getClockData(String data, uint8_t result[11]);
String getClockDatum(String data, int index);
int getDatumByte(int in1, int in2);

// global variables
String currentClockData = "0000";
String clockDataValues = "0123456789";

uint8_t matrixCustomPins[11][7] = {
    {0, 11, 22, 33, 44, 55, 66},  {1, 12, 23, 34, 45, 56, 67},
    {2, 13, 24, 35, 46, 57, 68},  {3, 14, 25, 36, 47, 58, 69},
    {4, 15, 26, 37, 48, 59, 70},  {5, 16, 27, 38, 49, 60, 71},
    {6, 17, 28, 39, 50, 61, 72},  {7, 18, 29, 40, 51, 62, 73},
    {8, 19, 30, 41, 52, 63, 74},  {9, 20, 31, 42, 53, 64, 75},
    {10, 21, 32, 43, 54, 65, 76},
};

uint8_t matrixCustomStates[11] = {
    0, 0, 54, 127, 127, 127, 62, 28, 8, 0, 0,
};

// matrix custom modes
uint16_t CUSTOM_MODE_CLOCK(void) {
  WS2812FX::Segment* seg = fx.getSegment();

  uint8_t matrixClockData[11] = {};
  getClockData(currentClockData, matrixClockData);

  for (int c = 0; c < 11; c++) {
    uint8_t d = matrixClockData[c];
    for (int r = 1; r < 8; r++) {
      byte a = bitRead(d, (7 - r));
      byte pin = matrixCustomPins[c][r - 1];
      fx.setPixelColor(pin, a ? fx.getColor() : BLACK);
    }
  }
  return seg->speed;
}

uint16_t CUSTOM_MODE_MATRIX(void) {
  WS2812FX::Segment* seg = fx.getSegment();

  for (int c = 0; c < 11; c++) {
    uint8_t d = matrixCustomStates[c];
    for (int r = 1; r < 8; r++) {
      byte a = bitRead(d, (7 - r));
      byte pin = matrixCustomPins[c][r - 1];
      fx.setPixelColor(pin, a ? fx.getColor() : BLACK);
    }
  }
  return seg->speed;
}

uint8_t clockByteValues[10][5] = {
    // 0
    {0b00000111, 0b00000101, 0b00000101, 0b00000101, 0b00000111},
    // 1
    {0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001},
    // 2
    {0b00000111, 0b00000001, 0b00000111, 0b00000100, 0b00000111},
    // 3
    {0b00000111, 0b00000001, 0b00000111, 0b00000001, 0b00000111},
    // 4
    {0b00000101, 0b00000101, 0b00000111, 0b00000001, 0b00000001},
    // 5
    {0b00000111, 0b00000100, 0b00000111, 0b00000001, 0b00000111},
    // 6
    {0b00000111, 0b00000100, 0b00000111, 0b00000101, 0b00000111},
    // 7
    {0b00000111, 0b00000001, 0b00000001, 0b00000001, 0b00000001},
    // 8
    {0b00000111, 0b00000101, 0b00000111, 0b00000101, 0b00000111},
    // 9
    {0b00000111, 0b00000101, 0b00000111, 0b00000001, 0b00000111},
};

void getClockData(String data, uint8_t result[11]) {
  int in1 = clockDataValues.indexOf(getClockDatum(data, 0));
  int in2 = clockDataValues.indexOf(getClockDatum(data, 1));
  int in3 = clockDataValues.indexOf(getClockDatum(data, 2));
  int in4 = clockDataValues.indexOf(getClockDatum(data, 3));

  //  uint8_t clock_data[11] = {};
  int data1_index = 0;
  for (int c = 0; c < 11; c++) {
    uint8_t data1 = 0b00000000;

    // col -> 0 ==> 0 - 4
    if (c >= 0 && c <= 4) {
      for (int r = 0; r < 3; r++) {
        if (r == 0) {
          data1 = getDatumByte(in1, data1_index);
        } else if (r == 1) {
          data1 = data1 << 4;
        } else if (r == 2) {
          data1 = data1 | getDatumByte(in2, data1_index);
        }
      }
    }

    // col -> 1 ==> 5
    else if (c == 5) {
      data1_index = -1;
    }

    // col -> 2 ==> 6 - 10
    else if (c >= 6 && c <= 10) {
      for (int r = 0; r < 3; r++) {
        if (r == 0) {
          data1 = getDatumByte(in3, data1_index);
        } else if (r == 1) {
          data1 = data1 << 4;
        } else if (r == 2) {
          data1 = data1 | getDatumByte(in4, data1_index);
        }
      }
    }

    // add data1 -> clock data
    data1_index++;
    result[c] = data1;
  }
}

String getClockDatum(String data, int index) {
  return data.substring(index, (index + 1));
}

int getDatumByte(int in1, int in2) { return clockByteValues[in1][in2]; }
#endif

int allModes[27] = {
    0,  1,  2,  3,  5,  7,  8,  11, 12, 13, 14, 15, 16, 17,
    18, 19, 20, 21, 22, 23, 29, 39, 40, 42, 43, 49, 55,
};

// global variables
String currentAutoMode = "off";
String currentMode = "0";
String currentBrightness = "100";
String currentSpeed = "1024";
String currentColor = "100.0.255";

void setup() {
  Serial.begin(115200);

#ifdef USE_ESP_NOW
  WiFi.mode(WIFI_STA);

  // Init ESP-NOW
  if (esp_now_init() != 0) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  // Once ESPNow is successfully Init, we will register for recv CB to
  // get recv packer info
  esp_now_set_self_role(ESP_NOW_ROLE_SLAVE);
  esp_now_register_recv_cb(onDataReceive);
#else
  Wire.begin(13);
  Wire.onReceive(receiveEvent);
  Wire.onRequest(requestEvent);
#endif

  pinMode(LED_PIN, OUTPUT);

  // initialize ws2812b
  fx.init();
  fx.setBrightness(100);
  fx.setColor(WS2812FX::Color(100, 0, 255));
  fx.setSpeed(1024);

#ifdef LM
  // set custom mode address
  // mode -> 57
  uint8_t customModeClock =
      fx.setCustomMode(F("Mode Clock"), CUSTOM_MODE_CLOCK);
  fx.setSegment(0, 0, LED_COUNT - 1, customModeClock, 0x007BFF, 1024);

  // mode -> 58
  uint8_t customModeMatrix =
      fx.setCustomMode(F("Mode Matrix"), CUSTOM_MODE_MATRIX);
  fx.setSegment(0, 0, LED_COUNT - 1, customModeMatrix, 0x007BFF, 1024);
#endif

  fx.setMode(FX_MODE_STATIC);
  fx.start();
}

unsigned long autoModePrevMillis = 0;
int autoModeIndex = 0;
void loop() {
  fx.service();

  if (currentAutoMode == "on") {
    unsigned long currentMillis = millis();
    if (currentMillis - autoModePrevMillis >= 15000) {
      autoModePrevMillis = currentMillis;

      fx.setMode(allModes[autoModeIndex]);

      if (autoModeIndex < 27)
        autoModeIndex++;
      else
        autoModeIndex = 0;
    }
  } else {
    if (fx.getMode() != currentMode.toInt()) fx.setMode(currentMode.toInt());
  }

  streamFXOptions();
}

unsigned long streamFXOptionsPrevMillis = 0;
void streamFXOptions() {
  unsigned long currentMillis = millis();
  if (currentMillis - streamFXOptionsPrevMillis >= 1000) {
    streamFXOptionsPrevMillis = currentMillis;

    if (fx.getBrightness() != currentBrightness.toInt())
      fx.setBrightness(currentBrightness.toInt());

    if (fx.getSpeed() != currentSpeed.toInt())
      fx.setSpeed(currentSpeed.toInt());

    // handle color
    int in1 = currentColor.indexOf(".");
    int in2 = currentColor.lastIndexOf(".");

    int r = currentColor.substring(0, in1).toInt();
    int g = currentColor.substring(in1 + 1, in2).toInt();
    int b = currentColor.substring(in2 + 1, currentColor.length()).toInt();

    fx.setColor(WS2812FX::Color(r, g, b));
  }
}

#ifdef USE_ESP_NOW
void onDataReceive(uint8_t* mac, uint8_t* incomingData, uint8_t len) {
  memcpy(&message, incomingData, sizeof(message));
  // Serial.print("Bytes received: ");
  // Serial.println(len);

  Serial.print("[");
  Serial.print(message.key);
  Serial.print("] ");
  Serial.println(message.value);

  const char* type = message.key;
  String data = String(message.value);

  if (strcmp(type, "a_m") == 0) currentAutoMode = data;
  if (strcmp(type, "m") == 0) currentMode = data;
  if (strcmp(type, "b") == 0) currentBrightness = data;
  if (strcmp(type, "s") == 0) currentSpeed = data;
  if (strcmp(type, "c") == 0) currentColor = data;
}
#else
void receiveEvent(int len) {
  String receiveData = "";
  while (Wire.available() > 0) {
    receiveData += (char)Wire.read();
  }

  int semicolonIndex = receiveData.indexOf(";");
  String type = receiveData.substring(0, semicolonIndex);
  String data = receiveData.substring(semicolonIndex + 1, receiveData.length());

  if (data.length() == 0) return;

  if (type == "a_m") currentAutoMode = data;
  if (type == "m") currentMode = data;
  if (type == "b") currentBrightness = data;
  if (type == "s") currentSpeed = data;
  if (type == "c") currentColor = data;

#ifdef LM
  if (type == "cd") currentClockData = data;
#endif

  Serial.print("[Receive data] ");
  Serial.print(type);
  Serial.print(" -> ");
  Serial.println(data);
}

void requestEvent() {}
#endif