import processing.serial.*;
import processing.sound.*;

// ============================================================
// SETTINGS
// ============================================================
final int PORT_INDEX = 2;      // Change if your Arduino is on another port
final int BAUD = 9600;         // Must match Arduino code

final int EASY_LIMIT_MS = 15000;    // 15 seconds
final int MEDIUM_LIMIT_MS = 10000;  // 10 seconds
final int HARD_LIMIT_MS = 5000;     // 5 seconds

final int SUCCESS_MS = 2000;
final int UPSET_MS = 3000;
final int AFFINITY_MAX = 30;
final int CELL = 40;
final int SLEEP_ANIM_MS = 700;

String currentMode = "MEDIUM";

Serial myPort;
SinOsc alarm;

boolean alarmPlaying = false;
boolean latePenaltyApplied = false;
int alarmStartMs = 0;

boolean toneOn = false;
int lastToneSwitchMs = 0;

String face = "NORMAL";
int affinity = 30;
String status = "Waiting for alarm";
int feedbackUntil = 0;

color OUTLINE = #7A6A78;
color CREAM   = #F7F3EE;
color PINK    = #F2A6B3;
color HEART   = #EE9AAE;
color TEAR    = #8ECAE6;
color BG      = #FDF8F4;


// ============================================================
// CAT FRAMES
// ============================================================
String[] FRAME_NORMAL = {
  "............",
  "............",
  "..#......#..",
  ".#.######.#.",
  ".#........#.",
  ".#..#..#..#.",
  ".#.p....p.#.",
  "..########.."
};

String[] FRAME_HAPPY = {
  "...##..##...",
  "....####....",
  "..#......#..",
  ".#.######.#.",
  ".#........#.",
  ".#..#..#..#.",
  ".#.p....p.#.",
  "..########.."
};

String[] FRAME_SUCCESS = {
  "............",
  "............",
  "..#......#..",
  ".#.######.#.",
  ".#.#....#.#.",
  ".#..#..#..#.",
  ".#.#....#.#.",
  "..########.."
};

String[] FRAME_UPSET = {
  "............",
  "............",
  "..#......#..",
  ".#.######.#.",
  ".#...##...#.",
  ".#..#..#..#.",
  ".#.p.##.p.#.",
  "..########.."
};

String[] FRAME_CRY = {
  "............",
  "............",
  "..#......#..",
  ".#.######.#.",
  ".#........#.",
  ".#.##..##.#.",
  ".#.b....b.#.",
  "..########.."
};

String[] FRAME_SLEEP_1 = {
  ".##.........",
  "..##........",
  "............",
  ".##########.",
  ".#........#.",
  ".#.##..##.#.",
  ".#.p....p.#.",
  "..########.."
};

String[] FRAME_SLEEP_2 = {
  ".##..##.....",
  "..##..##....",
  "............",
  ".##########.",
  ".#........#.",
  ".#.##..##.#.",
  ".#.p....p.#.",
  "..########.."
};

String[] FRAME_SLEEP_3 = {
  ".##..##..##.",
  "..##..##..##",
  "............",
  ".##########.",
  ".#........#.",
  ".#.##..##.#.",
  ".#.p....p.#.",
  "..########.."
};

String[] HEART_ICON = {
  ".##.##.",
  "#######",
  "#######",
  ".#####.",
  "..###..",
  "...#..."
};


// ============================================================
// SETUP
// ============================================================
void setup() {
  size(560, 680);
  surface.setTitle("Alarm + Pixel Cat");

  String[] ports = Serial.list();
  printArray(ports);

  if (ports.length > PORT_INDEX) {
    myPort = new Serial(this, ports[PORT_INDEX], BAUD);
    myPort.bufferUntil('\n');
    status = "Connected: " + ports[PORT_INDEX];
  } else {
    status = "No serial port at index " + PORT_INDEX;
  }

  alarm = new SinOsc(this);
}


// ============================================================
// DRAW
// ============================================================
void draw() {
  background(BG);

  // ==========================================================
  // ALARM BEEP PATTERN
  // ==========================================================
  if (alarmPlaying) {

    // EASY: continuous sound
    if (currentMode.equals("EASY")) {
      if (!toneOn) {
        alarm.play();
        toneOn = true;
      }
    }

    // MEDIUM / HARD: intermittent sound
    else {
      int interval;

      if (currentMode.equals("MEDIUM")) {
        interval = 1000;   // 1 second on / 1 second off
      }
      else {
        interval = 500;    // HARD: 0.5 second on / 0.5 second off
      }

      if (millis() - lastToneSwitchMs >= interval) {
        lastToneSwitchMs = millis();

        if (toneOn) {
          alarm.stop();
          toneOn = false;
        }
        else {
          alarm.play();
          toneOn = true;
        }
      }
    }
  }


  // ==========================================================
  // CHECK IF USER IS LATE
  // ==========================================================
  if (
    alarmPlaying &&
    !latePenaltyApplied &&
    millis() - alarmStartMs > getOnTimeLimit()
  ) {

    latePenaltyApplied = true;

    affinity -= 1;

    face = "UPSET";

    feedbackUntil = millis() + UPSET_MS;

    status = "LATE: affinity -1. Press button to dismiss.";
  }


  // ==========================================================
  // RETURN TO LONG-TERM CAT STATE
  // ==========================================================
  if (!alarmPlaying &&
      feedbackUntil > 0 &&
      millis() >= feedbackUntil) {

    feedbackUntil = 0;

    updateLongTermFace();
  }


  // Keep UPSET visible while alarm is still ringing
  if (alarmPlaying &&
      latePenaltyApplied &&
      feedbackUntil > 0 &&
      millis() >= feedbackUntil) {

    feedbackUntil = 0;

    face = "UPSET";
  }


  // ==========================================================
  // CAT
  // ==========================================================
  drawSprite(frameFor(face), 40, 30, CELL);


  // ==========================================================
  // STATE + AFFINITY
  // ==========================================================
  fill(OUTLINE);

  textAlign(LEFT, BASELINE);

  textSize(22);

  text("State: " + face, 40, 400);


  drawSprite(HEART_ICON, 40, 425, 8);

  textSize(40);

  text(affinity + " / " + AFFINITY_MAX, 115, 470);


  noFill();

  stroke(OUTLINE);

  rect(40, 495, 480, 18);


  noStroke();

  fill(HEART);

  rect(
    40,
    495,
    480.0 * constrain(affinity, 0, AFFINITY_MAX) / AFFINITY_MAX,
    18
  );


  // ==========================================================
  // ALARM STATUS
  // ==========================================================
  fill(OUTLINE);

  textSize(18);


  if (alarmPlaying) {

    float elapsed =
      (millis() - alarmStartMs) / 1000.0;

    text(
      "ALARM RINGING  " +
      nf(elapsed, 0, 1) +
      " s",
      40,
      555
    );

    text(
      "Press the button to dismiss",
      40,
      580
    );

    text(
      "Mode: " +
      currentMode +
      "  (Time limit: " +
      getOnTimeLimit()/1000 +
      " s)",
      40,
      605
    );
  }

  else {

    text(
      "Alarm ready",
      40,
      555
    );

    text(
      "Waiting for alarm",
      40,
      580
    );

    text(
      "Mode: " +
      currentMode +
      "  (Time limit: " +
      getOnTimeLimit()/1000 +
      " s)",
      40,
      605
    );
  }


  textSize(14);

  text(
    status,
    40,
    640
  );
}


// ============================================================
// START ALARM
// ============================================================
void startAlarm() {

  if (alarmPlaying) return;


  alarmPlaying = true;

  latePenaltyApplied = false;

  alarmStartMs = millis();

  feedbackUntil = 0;


  // RING wakes cat
  updateLongTermFace();

  status = "RING";


  // ==========================================================
  // TURN ON LED FOR CURRENT MODE
  // ==========================================================
  updateAlarmLED();


  // ==========================================================
  // FREQUENCY BY MODE
  // ==========================================================
  if (currentMode.equals("EASY")) {

    alarm.freq(700);

  }

  else if (currentMode.equals("MEDIUM")) {

    alarm.freq(1000);

  }

  else if (currentMode.equals("HARD")) {

    alarm.freq(1500);

  }


  alarm.amp(0.4);


  // ==========================================================
  // SOUND PATTERN START
  // ==========================================================
  if (currentMode.equals("EASY")) {

    alarm.play();

    toneOn = true;

  }

  else {

    alarm.stop();

    toneOn = false;

    lastToneSwitchMs = millis();

  }
}


// ============================================================
// DISMISS ALARM
// ============================================================
void dismissAlarm() {

  if (!alarmPlaying) return;


  int elapsed =
    millis() - alarmStartMs;


  alarm.stop();

  alarmPlaying = false;

  toneOn = false;

  // Turn off all LEDs after alarm is dismissed
  turnOffLEDs();


  // ==========================================================
  // ON TIME
  // ==========================================================
  if (
  !latePenaltyApplied &&
  elapsed <= getOnTimeLimit()
) {

  face = "SUCCESS";

  feedbackUntil =
    millis() + SUCCESS_MS;

  status =
    "ON_TIME: no health lost";
}


  // ==========================================================
  // LATE
  // ==========================================================
  else {

    face = "UPSET";

    feedbackUntil =
      millis() + UPSET_MS;

    status =
      "LATE: affinity -1";
  }
}


// ============================================================
// LONG-TERM CAT STATE
// ============================================================
void updateLongTermFace() {
  if (affinity == AFFINITY_MAX) {
    face = "HAPPY";
  }
  else if (affinity <= 0) {
    face = "CRY";
  }
  else {
    face = "NORMAL";
  }
}



// ============================================================
// GET ON-TIME LIMIT BASED ON MODE
// ============================================================
int getOnTimeLimit() {

  if (currentMode.equals("EASY")) {

    return EASY_LIMIT_MS;

  }

  else if (currentMode.equals("HARD")) {

    return HARD_LIMIT_MS;

  }

  else {

    return MEDIUM_LIMIT_MS;

  }
}


// ============================================================
// KEYBOARD BACKUP: S = DISMISS
// ============================================================
void keyPressed() {

  if (key == 's' || key == 'S') {

    dismissAlarm();

  }
}


// ============================================================
// SERIAL FROM ARDUINO
// ============================================================
void serialEvent(Serial p) {

  String message =
    p.readStringUntil('\n');


  if (message == null) return;


  message = trim(message);

  println(message);


  // Alarm trigger
  if (message.equals("ALARM")) {

    startAlarm();

  }


  // Physical dismiss button
  else if (message.equals("DISMISS")) {

    dismissAlarm();

  }


  // Mode selection
  else if (message.equals("MODE:EASY")) {

    currentMode = "EASY";

    if (alarmPlaying) {
      updateAlarmLED();
    }

  }

  else if (message.equals("MODE:MEDIUM")) {

    currentMode = "MEDIUM";

    if (alarmPlaying) {
      updateAlarmLED();
    }

  }

  else if (message.equals("MODE:HARD")) {

    currentMode = "HARD";

    if (alarmPlaying) {
      updateAlarmLED();
    }

  }
}


// ============================================================
// LED CONTROL
// ============================================================
void updateAlarmLED() {

  if (myPort == null) return;

  if (currentMode.equals("EASY")) {
    myPort.write("LED:EASY\n");      // Green
  }
  else if (currentMode.equals("MEDIUM")) {
    myPort.write("LED:MEDIUM\n");    // Yellow
  }
  else if (currentMode.equals("HARD")) {
    myPort.write("LED:HARD\n");      // Red
  }
}

void turnOffLEDs() {

  if (myPort == null) return;

  myPort.write("LED:OFF\n");
}


// ============================================================
// CAT FRAME SELECTION
// ============================================================
String[] frameFor(String name) {

  if (name.equals("HAPPY"))
    return FRAME_HAPPY;

  if (name.equals("CRY"))
    return FRAME_CRY;

  if (name.equals("SUCCESS"))
    return FRAME_SUCCESS;

  if (name.equals("UPSET"))
    return FRAME_UPSET;

  if (name.equals("SLEEP")) {

    int step =
      (millis() / SLEEP_ANIM_MS) % 3;

    if (step == 0)
      return FRAME_SLEEP_1;

    if (step == 1)
      return FRAME_SLEEP_2;

    return FRAME_SLEEP_3;
  }

  return FRAME_NORMAL;
}


// ============================================================
// DRAW CAT SPRITE
// ============================================================
void drawSprite(
  String[] rows,
  int x0,
  int y0,
  int cell
) {

  noStroke();


  for (int r = 0; r < rows.length; r++) {

    String row = rows[r];

    int first = -1;

    int last = -1;


    for (int c = 0; c < row.length(); c++) {

      if (row.charAt(c) != '.') {

        if (first < 0)
          first = c;

        last = c;

      }
    }


    for (int c = 0; c < row.length(); c++) {

      char ch =
        row.charAt(c);

      color col = 0;

      boolean on = true;


      if (ch == '#' || ch == 'z')
        col = OUTLINE;

      else if (ch == 'p')
        col = PINK;

      else if (ch == 'h')
        col = HEART;

      else if (ch == 'b')
        col = TEAR;

      else if (
        ch == '.' &&
        r >= 3 &&
        r <= 6 &&
        c > first &&
        c < last
      )
        col = CREAM;

      else
        on = false;


      if (on) {

        fill(col);

        rect(
          x0 + c * cell,
          y0 + r * cell,
          cell,
          cell
        );
      }
    }
  }
}
