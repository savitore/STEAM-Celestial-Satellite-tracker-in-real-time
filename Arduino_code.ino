String l0;
String l1;
String l2;
String str;
void setup() {
  Serial.begin(9600); //default baud rate for bt 38400
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
      i++;
      part = strtok(NULL, delimiter);
    }
    Serial.println(l0);
    Serial.println(l1);
    Serial.println(l2);

  }
}


