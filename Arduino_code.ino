#include <Servo.h>

Servo elevation; 
Servo azimuth;
String str;
String az;
String el;

int epos = 0;   
int apos = 0;

void setup() {
  elevation.attach(9); 
  azimuth.attach(10);
  elevation.write(epos);
  azimuth.write(apos);
  Serial.begin(9600); //default baud rate for bt 38400
  delay(5000); 
}


void loop() {
  if(Serial.available() > 0){ // Checks whether data is comming from the serial port
   str = Serial.readString(); // Reads the data from the serial port
    
   char buffer[str.length() + 1];
    str.toCharArray(buffer, sizeof(buffer));

    // Split the string into multiple parts using a delimiter
    char delimiter[] = ",";
    char* part = strtok(buffer, delimiter);
    int i=0;

    // Process the split parts
    while (part != NULL) {
      String partString = String(part);
      if(i==0){
        az=partString;
      }
      if(i==1){
        el=partString;
      }
      i++;
      part = strtok(NULL, delimiter);
    }

    
     elevation.write(0);
     azimuth.write(0);
     apos = az.toInt();
     epos = el.toInt();

     if (epos < 0) {
        Serial.println("Out of range. Please try another satellite.");
      } 
      else {
        Serial.println("In range, satellite can be viewed.");
        if(apos < 180) {  
          apos = abs(180 - (apos)); 
          epos = 180-epos; 
        } 
        else {  
          apos = (360-apos); 
          epos = epos; 
        }  
        azimuth.write(apos);  
        delay(15); 
        elevation.write(epos); 
        Serial.print("azimuth: ");
      Serial.println(apos);
      Serial.print("elevation: ");
      Serial.println(epos);
      }        

    
  }
    
}
