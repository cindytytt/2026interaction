//week03_5_processing_NS_SHAFT_02_draw_floor
//修改week03_4_processing_NS_SHAFT_01
//小朋友下樓梯
void setup(){
  size(600,600);
  for(int i=0;i<20;i++) floorX[i] = int(random(600-140));
}
int[]floorX = new int [20];//20個地板
void draw(){
  background(0,5,95);
  fill(47,105,190);//左右的磚塊
  for(int i=0;i<10;i++){
    rect(0, i*60,25,60);
    rect(600-25, i*60,25,60);
  }
  fill(208,216,189);//地板
  //rect(200,200,140,25);
  for(int i=0;i<20;i++){
    rect(floorX[i], 75+i*75,140,25);
  }
}
