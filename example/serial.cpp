#include "Arduino.h"
#include "SoftwareSerial.h"
#include "Wire.h"

void setup()
{
    SoftwareSerial serial(9, 10);
    serial.begin(9600);
    Wire.begin();
}

void loop()
{

}