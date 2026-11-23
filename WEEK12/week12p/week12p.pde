import processing.serial.*;

Serial myPort;
final String TARGET_PORT = "COM6"; // 直接指定接在 COM5

int joyDir = 0;      // -1: 左, 0: 中, 1: 右
int joyBtn = 0;      // 1: 搖桿中間按鈕按下, 0: 未按下

// 遊戲狀態：0 = 進行中, 1 = 死亡結算
int gameState = 0;

// 音效觸發旗標
boolean send100mCmdRequested = false;
boolean sendFallCmdRequested = false;
int lastMilestone100M = 0;

// 小鳥狀態
float birdX, birdY;
float birdVX = 0, birdVY = 0;
float birdSize = 32;
boolean facingLeft = false;

// 物理與高度參數
float gravity = 0.42;
float normalJumpVY = -12.5;
float superJumpVY = -22.0;
float cameraScrollThreshold = 240;

int currentHeightPx = 0;
int maxHeightPx = 0;
float pixelsPerMeter = 25.0;

// 遊戲結束畫面「中間重新開始按鈕」區域
float restartBtnX, restartBtnY, restartBtnW = 210, restartBtnH = 48;

ArrayList<Platform> platforms;
ArrayList<BoostItem> boosts;
ArrayList<Particle> particles;

void setup() {
  size(450, 750);
  textAlign(CENTER, CENTER);

  restartBtnX = width / 2.0 - restartBtnW / 2.0;
  restartBtnY = 445;

  connectCOM5();
  initGame();
}

void connectCOM5() {
  try {
    myPort = new Serial(this, TARGET_PORT, 9600);
    myPort.bufferUntil('\n');
    println("成功連接至 " + TARGET_PORT);
  } catch (Exception e) {
    println("無法連接 " + TARGET_PORT + "，請確認是否被其他程式佔用或埠號是否正確。");
    println("目前偵測到的序列埠：");
    printArray(Serial.list());
  }
}

void initGame() {
  gameState = 0;
  birdX = width / 2.0;
  birdY = height - 140;
  birdVX = 0;
  birdVY = normalJumpVY;

  currentHeightPx = 0;
  maxHeightPx = 0;
  lastMilestone100M = 0;
  send100mCmdRequested = false;
  sendFallCmdRequested = false;

  platforms = new ArrayList<Platform>();
  boosts = new ArrayList<BoostItem>();
  particles = new ArrayList<Particle>();

  // 最底部起跳木板
  platforms.add(new Platform(width / 2.0 - 45, height - 90, 90, 16, 0));

  float y = height - 165;
  while (y > -100) {
    spawnPlatformRow(y);
    y -= random(65, 95);
  }
}

void spawnPlatformRow(float y) {
  int type = pickPlatformType();
  float pw = (type == 2) ? 80 : 88;
  float px = random(20, width - pw - 20);
  platforms.add(new Platform(px, y, pw, 16, type));

  if (type != 2 && random(1) < 0.16) {
    boosts.add(new BoostItem(px + pw / 2.0, y - 14));
  }
}

int pickPlatformType() {
  float progress = constrain(maxHeightPx / 4000.0, 0, 1);
  float r = random(1);
  if (r < lerp(0.68, 0.40, progress)) {
    return 0; // 一般木板
  } else if (r < lerp(0.88, 0.72, progress)) {
    return 1; // 會動的木板
  } else {
    return 2; // 跳一次才會碎掉的木板
  }
}

void draw() {
  drawBackgroundGrid();

  if (gameState == 0) {
    updatePlaying();
    drawWorld();
    drawTopMeterHUD();
  } else if (gameState == 1) {
    drawWorld();
    drawTopMeterHUD();
    drawGameOverOverlay();
  }

  sendArduinoSoundCommands();
}

void sendArduinoSoundCommands() {
  if (myPort == null) return;

  if (send100mCmdRequested) {
    send100mCmdRequested = false;
    myPort.write('M');
    println("送出音效指令：M (100M 提示)");
  }

  if (sendFallCmdRequested) {
    sendFallCmdRequested = false;
    myPort.write('F');
    println("送出音效指令：F (掉落音效)");
  }
}

void drawBackgroundGrid() {
  background(252, 248, 238);
  stroke(235, 228, 212);
  strokeWeight(1);
  int step = 25;
  for (int x = 0; x < width; x += step) {
    line(x, 0, x, height);
  }
  for (int y = 0; y < height; y += step) {
    line(0, y, width, y);
  }
}

void updatePlaying() {
  int moveDir = joyDir;
  if (keyPressed) {
    if (keyCode == LEFT || key == 'a' || key == 'A') moveDir = -1;
    if (keyCode == RIGHT || key == 'd' || key == 'D') moveDir = 1;
  }

  if (moveDir != 0) {
    facingLeft = (moveDir < 0);
    birdVX = lerp(birdVX, moveDir * 6.2, 0.28);
  } else {
    birdVX = lerp(birdVX, 0, 0.18);
  }

  birdX += birdVX;

  if (birdX < -birdSize / 2) {
    birdX = width + birdSize / 2;
  } else if (birdX > width + birdSize / 2) {
    birdX = -birdSize / 2;
  }

  birdVY += gravity;
  birdY += birdVY;

  if (birdY < cameraScrollThreshold) {
    float deltaY = cameraScrollThreshold - birdY;
    birdY = cameraScrollThreshold;

    currentHeightPx += deltaY;
    if (currentHeightPx > maxHeightPx) {
      maxHeightPx = currentHeightPx;
    }

    int meters = max(0, round(maxHeightPx / pixelsPerMeter));
    int milestone = (meters / 100) * 100;
    if (milestone >= 100 && milestone > lastMilestone100M) {
      lastMilestone100M = milestone;
      send100mCmdRequested = true;
    }

    for (Platform p : platforms) p.y += deltaY;
    for (BoostItem b : boosts) b.y += deltaY;
    for (Particle pt : particles) pt.y += deltaY;
  }

  for (int i = platforms.size() - 1; i >= 0; i--) {
    Platform p = platforms.get(i);
    p.update();

    if (!p.broken && birdVY > 0) {
      float birdBottomPrev = (birdY - birdVY) + birdSize / 2;
      float birdBottomCurr = birdY + birdSize / 2;
      boolean withinX = (birdX + birdSize * 0.35 > p.x) && (birdX - birdSize * 0.35 < p.x + p.w);
      boolean crossedTop = (birdBottomPrev <= p.y + 6) && (birdBottomCurr >= p.y);

      if (withinX && crossedTop) {
        if (p.type == 2) {
          if (!p.cracked) {
            p.cracked = true;
            birdY = p.y - birdSize / 2;
            birdVY = normalJumpVY;
            spawnWoodParticles(p.x + p.w / 2, p.y + p.h / 2, color(185, 145, 95));
          } else {
            p.broken = true;
            spawnWoodParticles(p.x + p.w / 2, p.y + p.h / 2, color(155, 100, 55));
          }
        } else {
          birdY = p.y - birdSize / 2;
          birdVY = normalJumpVY;
        }
      }
    }

    if (p.y > height + 40) {
      platforms.remove(i);
      float highestY = getHighestPlatformY();
      spawnPlatformRow(highestY - random(68, 96));
    }
  }

  for (int i = boosts.size() - 1; i >= 0; i--) {
    BoostItem b = boosts.get(i);
    b.update();

    if (dist(birdX, birdY, b.x, b.y) < birdSize * 0.65 + b.r) {
      birdVY = superJumpVY;
      spawnWoodParticles(b.x, b.y, color(255, 195, 0));
      boosts.remove(i);
      continue;
    }

    if (b.y > height + 40) {
      boosts.remove(i);
    }
  }

  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle pt = particles.get(i);
    pt.update();
    if (pt.life <= 0) {
      particles.remove(i);
    }
  }

  if (birdY - birdSize / 2 > height) {
    gameState = 1;
    sendFallCmdRequested = true;
  }
}

float getHighestPlatformY() {
  float minY = height;
  for (Platform p : platforms) {
    if (p.y < minY) minY = p.y;
  }
  return minY;
}

void spawnWoodParticles(float cx, float cy, color c) {
  for (int i = 0; i < 12; i++) {
    particles.add(new Particle(cx + random(-15, 15), cy, random(-3.5, 3.5), random(-5, -1), c));
  }
}

void drawWorld() {
  for (Platform p : platforms) p.display();
  for (BoostItem b : boosts) b.display();
  for (Particle pt : particles) pt.display();
  drawBird(birdX, birdY, birdSize, facingLeft);
}

void drawBird(float x, float y, float s, boolean flipLeft) {
  pushMatrix();
  translate(x, y);
  if (flipLeft) scale(-1, 1);

  fill(255, 210, 50);
  stroke(60, 45, 20);
  strokeWeight(2);
  ellipse(0, 0, s, s * 0.9);

  fill(245, 175, 30);
  float wingAngle = (birdVY < 0) ? -0.45 : 0.25;
  pushMatrix();
  translate(-s * 0.12, 2);
  rotate(wingAngle);
  ellipse(0, 0, s * 0.45, s * 0.26);
  popMatrix();

  fill(255);
  noStroke();
  ellipse(s * 0.18, -s * 0.1, s * 0.26, s * 0.26);
  fill(20);
  ellipse(s * 0.22, -s * 0.1, s * 0.12, s * 0.12);

  fill(255, 115, 25);
  stroke(60, 45, 20);
  strokeWeight(1.5);
  triangle(s * 0.35, -2, s * 0.62, 3, s * 0.35, 8);

  popMatrix();
}

void drawTopMeterHUD() {
  int meters = max(0, round(maxHeightPx / pixelsPerMeter));

  noStroke();
  fill(45, 45, 45, 185);
  rect(0, 0, width, 54);

  fill(255);
  textSize(24);
  text(meters + " M", width / 2.0, 28);
}

void drawGameOverOverlay() {
  int finalMeters = max(0, round(maxHeightPx / pixelsPerMeter));

  fill(0, 0, 0, 145);
  noStroke();
  rect(0, 0, width, height);

  float boxW = 330;
  float boxH = 260;
  float boxX = (width - boxW) / 2.0;
  float boxY = (height - boxH) / 2.0;

  fill(255, 250, 240);
  stroke(70, 50, 30);
  strokeWeight(3);
  rect(boxX, boxY, boxW, boxH, 16);

  fill(50, 40, 30);
  textSize(28);
  text("GAME OEVER", width / 2.0, boxY + 46);

  fill(215, 95, 25);
  textSize(42);
  text(finalMeters + " M", width / 2.0, boxY + 106);

  restartBtnX = width / 2.0 - restartBtnW / 2.0;
  restartBtnY = boxY + 150;

  boolean hover = isMouseOverRestartBtn();
  fill(hover ? color(235, 115, 35) : color(215, 95, 25));
  stroke(70, 45, 20);
  strokeWeight(2);
  rect(restartBtnX, restartBtnY, restartBtnW, restartBtnH, 10);

  fill(255);
  textSize(18);
  text("TRY AGAIN", width / 2.0, restartBtnY + restartBtnH / 2.0);
}

boolean isMouseOverRestartBtn() {
  return mouseX >= restartBtnX && mouseX <= restartBtnX + restartBtnW &&
         mouseY >= restartBtnY && mouseY <= restartBtnY + restartBtnH;
}

void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line != null) {
    line = trim(line);
    String[] parts = split(line, ',');
    if (parts.length >= 2) {
      joyDir = int(parts[0]);
      int prevBtn = joyBtn;
      joyBtn = int(parts[1]);

      if (gameState == 1 && joyBtn == 1 && prevBtn == 0) {
        initGame();
      }
    }
  }
}

void mousePressed() {
  if (gameState == 1 && isMouseOverRestartBtn()) {
    initGame();
  }
}

void keyPressed() {
  if (gameState == 1 && (key == 'r' || key == 'R' || key == ' ')) {
    initGame();
  }
}

class Platform {
  float x, y, w, h;
  int type;
  float vx = 0;
  boolean cracked = false;
  boolean broken = false;

  Platform(float x, float y, float w, float h, int type) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.type = type;
    if (type == 1) {
      vx = random(1) < 0.5 ? -2.2 : 2.2;
    }
  }

  void update() {
    if (type == 1 && !broken) {
      x += vx;
      if (x <= 8) {
        x = 8;
        vx = abs(vx);
      } else if (x + w >= width - 8) {
        x = width - 8 - w;
        vx = -abs(vx);
      }
    }
  }

  void display() {
    if (broken) return;

    pushMatrix();
    translate(x, y);
    strokeWeight(2);

    if (type == 0) {
      fill(175, 115, 62);
      stroke(95, 58, 28);
      rect(0, 0, w, h, 5);
    } else if (type == 1) {
      fill(75, 165, 155);
      stroke(35, 95, 88);
      rect(0, 0, w, h, 5);
      fill(255);
      noStroke();
      triangle(10, h / 2, 16, h / 2 - 4, 16, h / 2 + 4);
      triangle(w - 10, h / 2, w - 16, h / 2 - 4, w - 16, h / 2 + 4);
    } else if (type == 2) {
      float sag = cracked ? 3 : 0;
      fill(cracked ? color(175, 130, 88) : color(205, 172, 132));
      stroke(125, 90, 55);
      rect(0, sag, w, h, 4);

      stroke(110, 70, 35);
      strokeWeight(cracked ? 2.2 : 1.3);
      line(w * 0.35, sag, w * 0.40, sag + h * 0.65);
      line(w * 0.40, sag + h * 0.65, w * 0.32, sag + h);
      if (cracked) {
        line(w * 0.68, sag, w * 0.62, sag + h * 0.6);
        line(w * 0.62, sag + h * 0.6, w * 0.72, sag + h);
      }
    }

    popMatrix();
  }
}

class BoostItem {
  float x, y, r = 11;
  float phase = random(TWO_PI);

  BoostItem(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    phase += 0.1;
  }

  void display() {
    float bob = sin(phase) * 3;
    pushMatrix();
    translate(x, y + bob);

    fill(255, 200, 20);
    stroke(160, 105, 0);
    strokeWeight(2);
    ellipse(0, 0, r * 2, r * 2);

    fill(140, 70, 0);
    noStroke();
    triangle(0, -6, -5, 1, 5, 1);
    rect(-2, 1, 4, 5);

    popMatrix();
  }
}

class Particle {
  float x, y, vx, vy, life = 30;
  color c;

  Particle(float x, float y, float vx, float vy, color c) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.c = c;
  }

  void update() {
    x += vx;
    y += vy;
    vy += 0.25;
    life -= 1.5;
  }

  void display() {
    noStroke();
    fill(red(c), green(c), blue(c), map(life, 0, 30, 0, 255));
    rect(x, y, 7, 7);
  }
}
