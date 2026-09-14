//week02_5a
//我想要把Arduino 跟processing 結合 在Processing 按下key123對應Arduino的DO REMI
import processing.serial.*;
Serial myPort;
void setup(){
  size(300,200);
  myPort = new Serial(this,"COM5",9600);
}
void draw(){
}
void keyPressed(){
    if (key=='1') myPort.write('1');
    if (key=='2') myPort.write('2');
    if (key=='3') myPort.write('3'); 
    println(key);
}
