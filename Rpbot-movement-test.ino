// ==========================
// Motor A - Left Motor
// ==========================
int enA = 9;   // PWM pin
int in1 = 8;
int in2 = 7;

// ==========================
// Motor B - Right Motor
// ==========================
int enB = 10;  // PWM pin
int in3 = 5;
int in4 = 4;


void setup() {

  // Motor A
  pinMode(enA, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);

  // Motor B
  pinMode(enB, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);
}


void loop() {

  // 1. Forward
  forward(150);
  delay(2000);

  stopRobot();
  delay(1000);


  // 2. Backward
  backward(150);
  delay(2000);

  stopRobot();
  delay(1000);


  // 3. Turn Left
  turnLeft(150);
  delay(1500);

  stopRobot();
  delay(1000);


  // 4. Turn Right
  turnRight(150);
  delay(1500);

  stopRobot();
  delay(1000);


  // 5. Spin Left
  spinLeft(150);
  delay(1500);

  stopRobot();
  delay(1000);


  // 6. Spin Right
  spinRight(150);
  delay(1500);

  stopRobot();
  delay(2000);
}


// ==================================================
// Individual Motor Functions
// ==================================================

// Left Motor Forward
void leftForward(int speed) {

  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH);

  analogWrite(enA, speed);
}


// Left Motor Backward
void leftBackward(int speed) {

  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);

  analogWrite(enA, speed);
}


// Right Motor Forward
void rightForward(int speed) {

  digitalWrite(in3, LOW);
  digitalWrite(in4, HIGH);

  analogWrite(enB, speed);
}


// Right Motor Backward
void rightBackward(int speed) {

  digitalWrite(in3, HIGH);
  digitalWrite(in4, LOW);

  analogWrite(enB, speed);
}


// ==================================================
// Whole Robot Functions
// ==================================================

// Forward
void forward(int speed) {

  leftForward(speed);
  rightForward(speed);
}


// Backward
void backward(int speed) {

  leftBackward(speed);
  rightBackward(speed);
}


// Turn Left
// Left wheel stops, right wheel moves forward
void turnLeft(int speed) {

  analogWrite(enA, 0);
  rightForward(speed);
}


// Turn Right
// Right wheel stops, left wheel moves forward
void turnRight(int speed) {

  leftForward(speed);
  analogWrite(enB, 0);
}


// Spin Left
// Left wheel backward, right wheel forward
void spinLeft(int speed) {

  leftBackward(speed);
  rightForward(speed);
}


// Spin Right
// Left wheel forward, right wheel backward
void spinRight(int speed) {

  leftForward(speed);
  rightBackward(speed);
}


// Stop
void stopRobot() {

  analogWrite(enA, 0);
  analogWrite(enB, 0);
}
