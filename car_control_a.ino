int enA = 9;
int in1 = 8;
int in2 = 7;

int enB = 10;
int in3 = 5;
int in4 = 4;

int ledPin = 2;


// ========================================
// SPEED SETTINGS
// ========================================

// Forward
int forwardSpeedA = 200;
int forwardSpeedB = 200;

// Backward
int backwardSpeedA = 200;
int backwardSpeedB = 200;

// Left turn
int leftSpeedA = 100;
int leftSpeedB = 200;

// Right turn
int rightSpeedA = 200;
int rightSpeedB = 80;

// Backward left turn
int backLeftSpeedA = 100;
int backLeftSpeedB = 200;

// Backward right turn
int backRightSpeedA = 200;
int backRightSpeedB = 80;

// Spin in place
int spinSpeedA = 200;
int spinSpeedB = 200;

// ========================================
// SPIN LED SETTINGS
// ========================================

bool spinning = false;

bool spinLedState = false;

unsigned long lastBlinkTime = 0;

const unsigned long blinkInterval = 1000;


// ========================================
// SETUP
// ========================================

void setup() {

  pinMode(enA, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);

  pinMode(enB, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);

  pinMode(ledPin, OUTPUT);

  Serial.begin(9600);

  stopMotors();
}


// ========================================
// LOOP
// ========================================

void loop() {

  if (Serial.available() > 0) {

    char command = Serial.read();


    // ------------------------------------
    // FORWARD
    // ------------------------------------

    if (command == 'F') {

      spinning = false;

      forward();
    }


    // ------------------------------------
    // BACKWARD
    // ------------------------------------

    else if (command == 'B') {

      spinning = false;

      backward();
    }


    // ------------------------------------
    // LEFT
    // ------------------------------------

    else if (command == 'L') {

      spinning = false;

      turnLeft();
    }


    // ------------------------------------
    // RIGHT
    // ------------------------------------

    else if (command == 'R') {

      spinning = false;

      turnRight();
    }

    else if (command == 'J') {

  spinning = false;

  turnBackwardLeft();
}

else if (command == 'K') {

  spinning = false;

  turnBackwardRight();
}


    // ------------------------------------
    // CLOCKWISE SPIN
    // P = right Shift
    // ------------------------------------

    else if (command == 'P') {

      startSpinBlink();

      spinClockwise();
    }


    // ------------------------------------
    // COUNTERCLOCKWISE SPIN
    // Q = left Shift
    // ------------------------------------

    else if (command == 'Q') {

      startSpinBlink();

      spinCounterClockwise();
    }


    // ------------------------------------
    // STOP
    // ------------------------------------

    else if (command == 'S') {

      spinning = false;

      stopMotors();
    }
  }


  // ======================================
  // BLINK LED DURING EITHER SPIN
  // ======================================

  if (spinning) {

    if (millis() - lastBlinkTime >= blinkInterval) {

      lastBlinkTime = millis();

      spinLedState = !spinLedState;

      digitalWrite(
        ledPin,
        spinLedState ? HIGH : LOW
      );
    }
  }
}


// ========================================
// START SPIN LED
// ========================================

void startSpinBlink() {

  // Only initialize when spin first starts
  if (!spinning) {

    spinning = true;

    spinLedState = true;

    digitalWrite(ledPin, HIGH);

    lastBlinkTime = millis();
  }
}


// ========================================
// FORWARD
// ========================================

void forward() {

  digitalWrite(ledPin, LOW);

  // Motor A forward
  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);

  // Motor B forward
  digitalWrite(in3, LOW);
  digitalWrite(in4, HIGH);

  analogWrite(enA, forwardSpeedA);
  analogWrite(enB, forwardSpeedB);
}


// ========================================
// BACKWARD
// ========================================

void backward() {

  digitalWrite(ledPin, LOW);

  // Motor A backward
  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH);

  // Motor B backward
  digitalWrite(in3, HIGH);
  digitalWrite(in4, LOW);

  analogWrite(enA, backwardSpeedA);
  analogWrite(enB, backwardSpeedB);
}


// ========================================
// TURN LEFT
// ========================================

void turnLeft() {

  digitalWrite(ledPin, HIGH);

  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);

  digitalWrite(in3, LOW);
  digitalWrite(in4, HIGH);

  analogWrite(enA, leftSpeedA);
  analogWrite(enB, leftSpeedB);
}


// ========================================
// TURN RIGHT
// ========================================

void turnRight() {

  digitalWrite(ledPin, HIGH);

  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);

  digitalWrite(in3, LOW);
  digitalWrite(in4, HIGH);

  analogWrite(enA, rightSpeedA);
  analogWrite(enB, rightSpeedB);
}

// ========================================
// BACKWARD LEFT
// ========================================

void turnBackwardLeft() {

  // turning = LED ON
  digitalWrite(ledPin, HIGH);

  // both wheels physically backward
  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH);

  digitalWrite(in3, HIGH);
  digitalWrite(in4, LOW);

  analogWrite(enA, backLeftSpeedA);
  analogWrite(enB, backLeftSpeedB);
}


// ========================================
// BACKWARD RIGHT
// ========================================

void turnBackwardRight() {

  // turning = LED ON
  digitalWrite(ledPin, HIGH);

  // both wheels physically backward
  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH);

  digitalWrite(in3, HIGH);
  digitalWrite(in4, LOW);

  analogWrite(enA, backRightSpeedA);
  analogWrite(enB, backRightSpeedB);
}

// ========================================
// CLOCKWISE SPIN
// Right Shift
// ========================================

void spinClockwise() {

  // Motor A forward
  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);

  // Motor B backward
  digitalWrite(in3, HIGH);
  digitalWrite(in4, LOW);

  analogWrite(enA, spinSpeedA);
  analogWrite(enB, spinSpeedB);
}


// ========================================
// COUNTERCLOCKWISE SPIN
// Left Shift
// ========================================

void spinCounterClockwise() {

  // Motor A backward
  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH);

  // Motor B forward
  digitalWrite(in3, LOW);
  digitalWrite(in4, HIGH);

  analogWrite(enA, spinSpeedA);
  analogWrite(enB, spinSpeedB);
}


// ========================================
// STOP
// ========================================

void stopMotors() {

  analogWrite(enA, 0);
  analogWrite(enB, 0);

  digitalWrite(in1, LOW);
  digitalWrite(in2, LOW);

  digitalWrite(in3, LOW);
  digitalWrite(in4, LOW);

  digitalWrite(ledPin, LOW);

  spinLedState = false;
}