//week09-1
//多元聲音不只用單獨的tone
//問AI能不能用wax或mp3
//修改PCM librarise 讓他用pin8發聲
// Experimental PCM output for Maker UNO pin D8 (ATmega328P 16 MHz).
// Uses Timer1 64 kHz interrupt and first-order pulse-density modulation.
// Maker UNO: turn ON the onboard BUZZER slide switch.
// Board selection: Arduino Uno / ATmega328P / 16 MHz.
// This sketch uses the local modified PCM.cpp, NOT the original D11 library.
#include "PCM.h"
#include "sounddata.h"

void setup() {
  startPlayback(sounddata_data, sounddata_length);
}

void loop() {
  // One-shot sample plays for 1 second. Press RESET to play again.
}
