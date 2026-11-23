const int VRX_PIN    = A0;
const int SW_PIN     = 2;
const int BUZZER_PIN = 8;

void setup() {
  Serial.begin(9600);
  pinMode(SW_PIN, INPUT_PULLUP);
  pinMode(BUZZER_PIN, OUTPUT);
}

void loop() {
  // 1. 讀取搖桿左右與中間按鈕
  int xVal = analogRead(VRX_PIN);
  int swVal = digitalRead(SW_PIN);

  int dir = 0;
  if (xVal < 420) {
    dir = -1; // 左
  } else if (xVal > 600) {
    dir = 1;  // 右
  }

  Serial.print(dir);
  Serial.print(",");
  Serial.println(swVal == LOW ? 1 : 0);

  // 2. 接收來自 Processing 的音效指令
  while (Serial.available() > 0) {
    char cmd = Serial.read();
    if (cmd == 'M') {
      play100MSound();
    } else if (cmd == 'F') {
      playFallSound();
    }
  }

  delay(20);
}

// 100M 里程碑提示音效（上揚三連音）
void play100MSound() {
  tone(BUZZER_PIN, 587, 110); // D5
  delay(120);
  tone(BUZZER_PIN, 784, 110); // G5
  delay(120);
  tone(BUZZER_PIN, 1047, 220); // C6
  delay(230);
  noTone(BUZZER_PIN);
}

// 掉下去掉落音效（頻率快速下滑）
void playFallSound() {
  for (int freq = 520; freq >= 150; freq -= 25) {
    tone(BUZZER_PIN, freq, 22);
    delay(20);
  }
  noTone(BUZZER_PIN);
}
