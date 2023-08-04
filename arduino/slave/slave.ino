#include <WS2812FX.h>
#include <Wire.h>

#define LED_COUNT 77
#define LED_PIN 9

// device config
#define LM

WS2812FX fx = WS2812FX(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

#ifdef LM
String clockData = "0000";

uint8_t matrixCustomPins[11][7] = {
  { 0, 11, 22, 33, 44, 55, 66 },
  { 1, 12, 23, 34, 45, 56, 67 },
  { 2, 13, 24, 35, 46, 57, 68 },
  { 3, 14, 25, 36, 47, 58, 69 },
  { 4, 15, 26, 37, 48, 59, 70 },
  { 5, 16, 27, 38, 49, 60, 71 },
  { 6, 17, 28, 39, 50, 61, 72 },
  { 7, 18, 29, 40, 51, 62, 73 },
  { 8, 19, 30, 41, 52, 63, 74 },
  { 9, 20, 31, 42, 53, 64, 75 },
  { 10, 21, 32, 43, 54, 65, 76 },
};

uint8_t matrixCustomStates[11] = {
  0,
  0,
  54,
  127,
  127,
  127,
  62,
  28,
  8,
  0,
  0,
};

uint16_t CUSTOM_MODE_CLOCK(void) {
  WS2812FX::Segment* seg = fx.getSegment();

  uint8_t matrixClockData[11] = {};
  getClockData(clockData, matrixClockData);

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
#endif

void setup() {
  Serial.begin(115200);
  Wire.begin(13);
  Wire.onReceive(receiveEvent);
  Wire.onRequest(requestEvent);

  pinMode(LED_PIN, OUTPUT);

  // initialize ws2812b
  fx.init();
  fx.setBrightness(100);
  fx.setColor(BLUE);
  fx.setSpeed(1024);

#ifdef LM
  // set custom mode address
  // mode -> 57
  uint8_t customModeClock = fx.setCustomMode(F("Mode Clock"), CUSTOM_MODE_CLOCK);
  fx.setSegment(0, 0, LED_COUNT - 1, customModeClock, 0x007BFF, 1024);

  // mode -> 58
  uint8_t customModeMatrix = fx.setCustomMode(F("Mode Matrix"), CUSTOM_MODE_MATRIX);
  fx.setSegment(0, 0, LED_COUNT - 1, customModeMatrix, 0x007BFF, 1024);
#endif

  fx.setMode(11);
  fx.start();
}

void loop() {
  fx.service();
}

void receiveEvent(int len) {
  String receiveData = "";
  while (Wire.available() > 0) {
    receiveData += (char)Wire.read();
  }

  int semicolonIndex = receiveData.indexOf(";");
  String type = receiveData.substring(0, semicolonIndex);
  String data = receiveData.substring(semicolonIndex + 1, receiveData.length());

  if (type == "m") {
    int mode = data.toInt();
    if (fx.getMode() != mode) {
      fx.setMode(mode);
    }
  } else if (type == "b") {
    int brightness = data.toInt();
    if (fx.getBrightness() != brightness) {
      fx.setBrightness(brightness);
    }
  } else if (type == "s") {
    int speed = data.toInt();
    if (fx.getSpeed() != speed) {
      fx.setSpeed(speed);
    }
  } else if (type == "c") {
    int in1 = data.indexOf(".");
    int in2 = data.lastIndexOf(".");

    int r = data.substring(0, in1).toInt();
    int g = data.substring(in1 + 1, in2).toInt();
    int b = data.substring(in2 + 1, data.length()).toInt();

    // Serial.print(r);
    // Serial.print(" - ");
    // Serial.print(g);
    // Serial.print(" - ");
    // Serial.println(b);

    fx.setColor(WS2812FX::Color(r, g, b));
  }

#ifdef LM
  else if (type == "cd") {
    clockData = data;
  }
#endif

  Serial.print("[Receive data] ");
  Serial.print(type);
  Serial.print(" -> ");
  Serial.println(data);
}

void requestEvent() {}