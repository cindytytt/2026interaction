//week06-1_pin_2
void setup() {
  pinMode(2, INPUT_PULLUP);
  pinMode(8, OUTPUT);
  tone(8,523,100);//開啟時發聲

}

void loop() {
  if ( digitalRead(2) ==LOW){
    tone(8,523,100);//0.1秒
    delay(100);//等一下
    }

}
