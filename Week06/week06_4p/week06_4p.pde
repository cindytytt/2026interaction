//week06_4_p
//改自week06_3
import processing.serial.*;
Serial myPort;
void setup(){
  size(500,500);
  myPort = new Serial(this,"COM5",9600);
}
int now = 0;//現在的角度
int dd = 1;
void draw(){
  if(myPort.available()>0){
    if(myPort.read()=='1')dd = -1;
    else dd = 1;
  }
  background(0);//背景黑色
  translate(250,250);
  now += dd;
  rotate(radians(now));//持續轉動
  rect(-200,-200,400,400);
}
void mousePressed(){
  if (dd==1)dd = -1;//正變付
  else dd=1;
}
