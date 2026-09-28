#include "RTC.h"
#include "Arduino_LED_Matrix.h"

ArduinoLEDMatrix matrix;

// 3 x 5 font
const byte digits[10][5] = {
  {0b111, 0b101, 0b101, 0b101, 0b111}, // 0
  {0b010, 0b110, 0b010, 0b010, 0b111}, // 1
  {0b111, 0b001, 0b111, 0b100, 0b111}, // 2
  {0b111, 0b001, 0b111, 0b001, 0b111}, // 3
  {0b101, 0b101, 0b111, 0b001, 0b001}, // 4
  {0b111, 0b100, 0b111, 0b001, 0b111}, // 5
  {0b111, 0b100, 0b111, 0b101, 0b111}, // 6
  {0b111, 0b001, 0b001, 0b001, 0b001}, // 7
  {0b111, 0b101, 0b111, 0b101, 0b111}, // 8
  {0b111, 0b101, 0b111, 0b001, 0b111}  // 9
};

byte frame[8][12];

void clearFrame() {
  for (int row = 0; row < 8; row++) {
    for (int col = 0; col < 12; col++) {
      frame[row][col] = 0;
    }
  }
}

void drawDigit(int number, int startColumn) {
  for (int row = 0; row < 5; row++) {
    for (int col = 0; col < 3; col++) {
      if (digits[number][row] & (1 << (2 - col))) {
        frame[row + 1][startColumn + col] = 1;
      }
    }
  }
}

void displayTwoDigits(int number) {
  clearFrame();

  int firstDigit = number / 10;
  int secondDigit = number % 10;

  drawDigit(firstDigit, 2);
  drawDigit(secondDigit, 7);

  matrix.renderBitmap(frame, 8, 12);
}

void setup() {
  RTC.begin();
  matrix.begin();

  /*
  // ONLY use once to synchronize this board.
  // Change these values to the real time before uploading.

  RTCTime startTime(
    25,
    Month::SEPTEMBER,
    2026,
    15,
    30,
    00,
    DayOfWeek::FRIDAY,
    SaveLight::SAVING_TIME_ACTIVE
  );

  RTC.setTime(startTime);
  */
}

void loop() {
  RTCTime currentTime;
  RTC.getTime(currentTime);

  int hour = currentTime.getHour();

  displayTwoDigits(hour);

  delay(200);
}