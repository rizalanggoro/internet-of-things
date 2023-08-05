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

### Topics

Prefix topic : `com.anggoro.iot/{secret_key}/{device_id}`

#### Sub (Flutter App ke ESP)

Flutter App (publish) -> broker -> ESP (subscribe)

- Config : `{prefix}/sub/config`
  - Tipe data : String (JSON)
  - Contoh : `{any}`
- Mode : `{prefix}/sub/mode`
  - Tipe data : String
  - Contoh : `0-58`
- Brightness : `{prefix}/sub/brightness`
  - Tipe data : String
  - Contoh : `0-255`
- Speed : `{prefix}/sub/speed`
  - Tipe data : String
  - Contoh : `0-infinity`
- Color : `{prefix}/sub/color`
  - Tipe data : String
  - Contoh : `[0-255].[0-255].[0-255]` (red.green.blue)
- Save : `{prefix}/sub/save`
  - Tipe data : String
  - Contoh : `{any}`

#### Pub (ESP ke Flutter App)

ESP (publish) -> broker -> Flutter App (subscribe)

- Uptime : `{prefix}/pub/uptime`
  - Tipe data : String
  - Contoh : `12345` (dalam satuan ms)
- Heap : `{prefix}/pub/heap`
  - Tipe data : String
  - Contoh : `12345` (dalam satuan bytes)
- Config : `{prefix}/pub/config`
  - Tipe data : String (JSON)
  - Contoh : `{"mode": 1, ...}`

<hr />

## Dokumentasi Flutter

- Packages :
  1. flutter_bloc
  2. bloc
  3. go_router
  4. mqtt_client
  5. get_it
