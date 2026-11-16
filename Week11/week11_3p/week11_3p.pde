//week11-3-processing
import processing.serial.*;
Serial myPort;
void setup(){
  size (512,512);
  myPort = new Serial(this,"COM5",9600);
}
int x= 0,y= 0,sw= 0;
void draw(){
  background(255);
  if (myPort.available()>=3){
    x=(int) myPort.read();
    y=(int) myPort.read();
    sw=(int) myPort.read();
  }
  ellipse(x+128,y+128,8,8);
}
