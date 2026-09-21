//week03_1 
//迎新宿營會用LED發光
void setup() {
  pinMode(2,INPUT_PULLUP);//第2是按鈕 沒按時拉高
  for (int i=3;i<=3;i++) pinMode(i,OUTPUT);
  
}

void loop() {
  if (digitalRead(2)==HIGH){//沒有按下去
    for (int i=3;i<=7;i++) digitalWrite(i,HIGH);
    for (int i=9;i<=13;i++) digitalWrite(i,LOW);
    }else{
      for (int i=3;i<=7;i++) digitalWrite(i,LOW);
      for (int i=8;i<=13;i++) digitalWrite(i,HIGH);
    }
}
