# Internet of Things (IoT)

Projek internet of things menggunakan protokol MQTT untuk saling berkomunikasi antara aplikasi android (flutter) dengan nodemcu/esp8266 (arduino).

## Daftar Perangkat

### 1. Matrix

Menggunakan dua buah mikrokontroller yaitu, arduino nano sebagai slave dan esp8266 sebagai master. Kedua mikrokontroller tersebut saling berkomunikasi serial menggunakan I2C dengan rangkaian seperti berikut.

| ESP8266    | Arduino |
| ---------- | ------- |
| D1 (GPIO5) | A4      |
| D2 (GPIO4) | A5      |
| GND        | GND     |

ESP8266 bertindak sebagai master dan Arduino bertindak sebagai slave dengan address 13.

#### Device Config

- LED count : `77`
- LED pin : `9` (Arduino nano)
- Device ID : `ESP8266-Matrix`

<hr />

## Dokumentasi MQTT

- Broker : `broker.hivemq.com`
- Port : `1883`
- Prefix topic : `com.anggoro.iot/{secret_key}/{device_id}`
- Topics :
  1. mode : `{prefix}/mode`
  2. brightness : `{prefix}/brightness`
  3. speed : `{prefix}/speed`
  4. color : `{prefix}/color`

### Topic Mode

- Publish message : `0-58`
- Type : String
- Example : `13`

### Topic Brightness

- Publish message : `0-255`
- Type : String
- Example : `100`

### Topic Speed

- Publish message : `0-16000`
- Type : String
- Example : `1024`

### Topic Color

- Publish message : `0-255.0-255.0-255`
- Type : String (red.green.blue)
- Example : `255.0.100`
