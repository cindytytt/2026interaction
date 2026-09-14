//week_4
void setup() {
  // put your setup code here, to run once:
  pinMode(8,OUTPUT);
//只做一次
  tone(8,523,1000);//DO 1秒
  delay(1000);
  tone(8,587,1000);//RE 1秒
  delay(1000);
  tone(8,659,1000);//Mi 1秒
  delay(1000);
}

void loop() {
  // put your main code here, to run repeatedly:
//下面迴圈 會重複
}
