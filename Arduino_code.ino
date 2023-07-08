#include <ArduinoP13.h>
#include <Servo.h>
#include <TimeLib.h>

Servo elevation; 
Servo azimuth;
String l0;
String l1;
String l2;
String str;
String str1;
String read;
int CurrentHour=16; 
int CurrentMin=51; 
int CurrentSec=5; 
int CurrentDay=8; 
int CurrentMonth=7; 
int CurrentYear=2023;
char acBuffer[20];
const char  *pcMyName = "krishna";     // Observer name
double dMyLAT;    
double dMyLON;    
double dMyALT;  

int epos = 0;   
int apos = 0;
double dSatLAT  = 0; // Satellite latitude<br&gt 
double dSatLON  = 0; // Satellite longitude  
double dSatAZ   = 0; // Satellite azimuth<br&gt 
double dSatEL   = 0; // Satellite elevation 

void setup() {
  setTime(CurrentHour,CurrentMin,CurrentSec,CurrentDay,CurrentMonth,CurrentYear);
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
    char delimiter[] = "\n";
    char* part = strtok(buffer, delimiter);
    int i=0;

    // Process the split parts
    while (part != NULL) {
      String partString = String(part);
      if(i==0){
        l0=partString;
      }
      if(i==1){
        l1=partString;
      }
      if(i==2){
        l2=partString;
      }
      if(i==3){
        str1=partString;
      }

      i++;
      part = strtok(NULL, delimiter);
    }
    char buffer1[str1.length() + 1];
    str1.toCharArray(buffer1, sizeof(buffer1));

    // Split the string into multiple parts using a delimiter
    char delimiter1[] = ",";
    char* part1 = strtok(buffer1, delimiter1);
    int j=0;

    // Process the split parts
    while (part1 != NULL) {
      String partString = String(part1);
      if(j==0){
        CurrentYear=partString.toInt();
      }
      if(j==1){
        CurrentMonth=partString.toInt();
      }
      if(j==2){
        CurrentDay=partString.toInt();
      }
      if(j==3){
        CurrentHour=partString.toInt();
      }
      if(j==4){
        CurrentMin=partString.toInt();
      }
      if(j==5){
        CurrentSec=partString.toInt();
      }
      if(j==6){
        dMyLAT=partString.toDouble();
      }
      if(j==7){
        dMyLON=partString.toDouble();
      }
      if(j==8){
        dMyALT=partString.toDouble();
      }
      j++;
      part1 = strtok(NULL, delimiter1);
    }
     setTime(CurrentHour,CurrentMin,CurrentSec,CurrentDay,CurrentMonth,CurrentYear);//set the current time which we get from flutter app
     read="done";
  }
     if(read=="done"){

     char *tleName = l0.c_str();
     char *tlel1 = l1.c_str();
     char *tlel2 = l2.c_str();
     
     //using time library to calcuate azimuth and elevation for ongoing time
     int iYear    = year(); // Set start year  
     int iMonth   = month(); // Set start month  
     int iDay     = day();   // Set start day    
     int iHour    = hour();  // Set start hour [ substract -6 from current time ]  
     int iMinute  = minute(); // Set start minute   
     int iSecond  = second(); // Set start second<br&gt 
      P13Sun Sun; // Create object for the sun   
      P13DateTime MyTime(iYear, iMonth, iDay, iHour, iMinute, iSecond); // Set start time for the prediction  
      P13Observer MyQTH(pcMyName, dMyLAT, dMyLON, dMyALT);              // Set observer coordinates  
      P13Satellite MySAT(tleName, tlel1, tlel2);                        // Create ISS data from TLE
      MyTime.ascii(acBuffer);
      MySAT.predict(MyTime);              // Predict ISS for specific time  
      MySAT.latlon(dSatLAT, dSatLON);     // Get the rectangular coordinates  
      MySAT.elaz(MyQTH, dSatEL, dSatAZ);  // Get azimut and elevation for MyQTH
      delay(500);
      // Servo calculation  
      epos = (int)dSatEL; 
      apos = (int)dSatAZ;
      if (epos < 0) {
        // Serial.write("Out of range, Can't view satellite.");
      } else {
        // Serial.write("In range, Satellite can be viewed.");  
        if(apos < 180) {  
          apos = abs(180 - (apos)); 
          epos = 180-epos; 
        } else {  
          apos = (360-apos); 
          epos = epos; 
        }  
      azimuth.write(apos);  
      delay(15); 
      elevation.write(epos); 
      }
    Serial.println(l0);
    Serial.println(l1);
    Serial.println(l2);
    Serial.println(dMyLAT);
    Serial.println(dMyLON);
    Serial.println(dMyALT);
    Serial.println(dSatEL);
    Serial.println(dSatAZ);
    Serial.println(apos);
    Serial.println(epos);
     }
    
}

