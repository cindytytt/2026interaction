//week02_5_
//我想要把Arduino 跟processing 結合 在Processing 按下key123對應Arduino的DO REMI
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available()){
    char c=Serial.read();
    if (c=='1') tone(8,523,1000);
    if (c=='2') tone(8,587,1000);
    if (c=='3') tone(8,659,1000);  
    
  }
}
