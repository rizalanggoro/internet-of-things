#ifdef LM
WiFiUDP ntpUdp;
NTPClient ntpClient(ntpUdp, "id.pool.ntp.org", 25200);

String _ntp_clock_data = "0000";

void beginNtp() {
  ntpClient.begin();
}

void streamNtp() {
  ntpClient.update();

  int hour = ntpClient.getHours();
  int minute = ntpClient.getMinutes();
  String h = "";
  String m = "";

  if (hour < 10) h = "0" + String(hour);
  else h = String(hour);
  if (minute < 10) m = "0" + String(minute);
  else m = String(minute);

  _ntp_clock_data = h + m;
}

String getClockData() {
  return _ntp_clock_data;
}
#endif
