#include <ArduinoP13.h>
#include <Servo.h>
#include <TimeLib.h>
#include <Math.h>

Servo elevation; 
Servo azimuth;
String l0;
String l1;
String l2;
String str;
String str1;
String read;
int CurrentHour=14; 
int CurrentMin=57; 
int CurrentSec=5; 
int CurrentDay=9; 
int CurrentMonth=7; 
int CurrentYear=2023;
const float R = 6371.0;
char acBuffer[20];
const char  *pcMyName = ""; // Observer name
double dMyLAT;    
double dMyLON;    
double dMyALT;  

int epos = 0;   
int apos = 0;
double dSatLAT  = 0; // Satellite latitude
double dSatLON  = 0; // Satellite longitude
double dSatAZ   = 0; // Satellite azimuth
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

// Function to calculate the azimuth & elevation angles
void calculateAngles(double lat_ref, double lon_ref, double lat_sat, double lon_sat,
                     double& azimuth, double& elevation) {

  // Convert degrees to radians
  lat_ref = radians(lat_ref);
  lon_ref = radians(lon_ref);
  lat_sat = radians(lat_sat);
  lon_sat = radians(lon_sat);

  // Calculate differences in longitude & latitude
  double d_lon = lon_sat - lon_ref;
  double d_lat = lat_sat - lat_ref;


  // Calculate azimuth angle in radians
  float x = cos(lat_ref) * sin(lat_sat) - sin(lat_ref) * cos(lat_sat) * cos(d_lon);
  float y = cos(lat_sat) * sin(d_lon);
  float azimuth_rad = atan2(y, x);

  // Convert azimuth angle from radians to degrees
  azimuth = degrees(azimuth_rad);
  if (azimuth < 0) {
    azimuth += 360.0;
  }

  // Calculate elevation angle in radians
  float z = sin(lat_ref) * sin(lat_sat) + cos(lat_ref) * cos(lat_sat) * cos(d_lon);
  float elevation_rad = asin(z);

  // Convert elevation angle from radians to degrees
  elevation = degrees(elevation_rad);
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
     elevation.write(0);
     azimuth.write(0);
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
      delay(500);
      calculateAngles(dMyLAT, dMyLON, dSatLAT, dSatLON, dSatAZ, dSatEL);
      // Servo calculation  
      epos = (int)dSatEL; 
      apos = (int)dSatAZ;    

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
      }        

      // Serial.print("azimuth: ");
      // Serial.println(apos);
      // Serial.print("elevation: ");
      // Serial.println(epos);
     }
    
}
