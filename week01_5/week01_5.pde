//week01-5
float circleSize = 50; // 初始圓形大小

void setup() {
  size(400, 400);
}

void draw() {
  background(220);
  ellipse(width/2, height/2, circleSize, circleSize);
}

// 監聽滑鼠滾輪事件
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  
  // 根據滾輪方向調整數值
  circleSize += e * 5; 
  
  // 限制圓形大小的範圍（可選）
  circleSize = constrain(circleSize, 10, 300);
}
