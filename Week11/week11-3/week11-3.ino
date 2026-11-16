//week11-3
void setup() {
  Serial.begin(9600);
  pinMode(2,INPUT_PULLUP);
}

  int myAnalogRead(int pin){
    return map(analogRead(pin),0,1023,0,255);
    }
  void loop(){
    delay(300);
    Serial.write(myAnalogRead(A0));
    Serial.write(myAnalogRead(A1));
     if(digitalRead(2)==LOW)Serial.print("D");
     else Serial.print("U");
  
}
