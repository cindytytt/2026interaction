//week11-1-arduino_joystick
//加入joystick_A0_A1
void setup() {
  // put your setup code here, to run once:

}

void loop() {
  // put your main code here, to run repeatedly:
  int x=analogRead(A0);//讀入x
  int y=analogRead(A1);//
  tone(8,x);//有聲音
}
