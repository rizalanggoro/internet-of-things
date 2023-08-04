#ifdef LM
String _clock_data1 = "0123456789";
uint8_t _clock_data2[10][5] = {
  // 0
  {
    0b00000111,
    0b00000101,
    0b00000101,
    0b00000101,
    0b00000111
  },
  // 1
  {
    0b00000001,
    0b00000001,
    0b00000001,
    0b00000001,
    0b00000001
  },
  // 2
  {
    0b00000111,
    0b00000001,
    0b00000111,
    0b00000100,
    0b00000111
  },
  // 3
  {
    0b00000111,
    0b00000001,
    0b00000111,
    0b00000001,
    0b00000111
  },
  // 4
  {
    0b00000101,
    0b00000101,
    0b00000111,
    0b00000001,
    0b00000001
  },
  // 5
  {
    0b00000111,
    0b00000100,
    0b00000111,
    0b00000001,
    0b00000111
  },
  // 6
  {
    0b00000111,
    0b00000100,
    0b00000111,
    0b00000101,
    0b00000111
  },
  // 7
  {
    0b00000111,
    0b00000001,
    0b00000001,
    0b00000001,
    0b00000001
  },
  // 8
  {
    0b00000111,
    0b00000101,
    0b00000111,
    0b00000101,
    0b00000111
  },
  // 9
  {
    0b00000111,
    0b00000101,
    0b00000111,
    0b00000001,
    0b00000111
  },
};

void getClockData(String data, uint8_t result[11]) {
  int in1 = _clock_data1.indexOf(_clock_getData(data, 0));
  int in2 = _clock_data1.indexOf(_clock_getData(data, 1));
  int in3 = _clock_data1.indexOf(_clock_getData(data, 2));
  int in4 = _clock_data1.indexOf(_clock_getData(data, 3));

  //  uint8_t clock_data[11] = {};
  int data1_index = 0;
  for (int c = 0; c < 11; c++) {
    uint8_t data1 = 0b00000000;

    // col -> 0 ==> 0 - 4
    if (c >= 0 && c <= 4) {
      for (int r = 0; r < 3; r++) {
        if (r == 0) {
          data1 = _clock_getByteData(in1, data1_index);
        } else if (r == 1) {
          data1 = data1 << 4;
        } else if (r == 2) {
          data1 = data1 | _clock_getByteData(in2, data1_index);
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
          data1 = _clock_getByteData(in3, data1_index);
        } else if (r == 1) {
          data1 = data1 << 4;
        } else if (r == 2) {
          data1 = data1 | _clock_getByteData(in4, data1_index);
        }
      }
    }

    // add data1 -> clock data
    data1_index++;
    result[c] = data1;
  }
}

String _clock_getData(String data, int index) {
  return data.substring(index, (index + 1));
}

int _clock_getByteData(int in1, int in2) {
  return _clock_data2[in1][in2];
}
#endif
