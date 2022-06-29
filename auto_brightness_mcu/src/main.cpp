#include <Arduino.h>
#include <Wire.h>
#include <BH1750.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>

const char *ssid = "abcd";         //修改WIFI名称
const char *password = "12345678"; //修改WIFI密码

BH1750 lightMeter;
WiFiUDP udp;

void setup()
{
  Serial.begin(9600);
  Wire.begin();
  lightMeter.begin();
  WiFi.mode(WIFI_STA);
  WiFi.setAutoConnect(true);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
  }
}

void loop()
{
  float lux = lightMeter.readLightLevel();
  Serial.println((int)lux);
  udp.beginPacket("255.255.255.255", 8888);
  udp.print((int)lux);
  udp.endPacket();
  delay(1000);
}
