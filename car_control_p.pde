import processing.serial.*;

Serial myPort;


// ============================================================
// CONTROL
// ============================================================

boolean enabled = false;
boolean spaceHeld = false;

String status = "STOP";


// ============================================================
// ANIMATION
// ============================================================

float roadOffset = 0;
float catBob = 0;


// ============================================================
// COLORS
// ============================================================

color BG       = color(234, 228, 224);
color BLACK    = color(0);
color WHITE    = color(255);
color PINK     = color(245, 196, 214);
color BLUE     = color(74, 213, 255);
color SHADOW   = color(205, 198, 194);

color ROAD     = color(65);
color ROADLINE = color(230);


// ============================================================
// SETUP
// ============================================================

void setup() {

  size(800, 500);

  noSmooth();
  noStroke();

  printArray(Serial.list());

  // Arduino is port 2
  myPort = new Serial(this, Serial.list()[2], 9600);

  textAlign(CENTER, CENTER);
}


// ============================================================
// DRAW
// ============================================================

void draw() {

  background(BG);


  // ==========================================================
  // ROAD / WORLD MOVEMENT
  // ==========================================================

  if (enabled) {


    // --------------------------------------------------------
    // BACKWARD
    // --------------------------------------------------------

    if (
      status.equals("BACKWARD") ||
      status.equals("BACK LEFT") ||
      status.equals("BACK RIGHT")
    ) {

      roadOffset -= 5;
    }


    // --------------------------------------------------------
    // FORWARD
    // --------------------------------------------------------

    else if (
      status.equals("FORWARD") ||
      status.equals("LEFT") ||
      status.equals("RIGHT")
    ) {

      roadOffset += 5;
    }


    // SPIN:
    // roadOffset does not change
  }


  // ==========================================================
  // CAT BOB
  // ==========================================================

  if (
    enabled &&
    !status.equals("STOP")
  ) {

    catBob =
      sin(frameCount * 0.30) * 3;

  } else {

    catBob = 0;
  }


  drawScene();

  drawStatus();
}


// ============================================================
// SCENE
// ============================================================

void drawScene() {


  // ==========================================================
  // BACKGROUND OBJECTS
  // ==========================================================

  for (int i = -2; i < 8; i++) {

    float x =
      i * 180
      - (roadOffset % 180);


    drawCactus(
      x + 35,
      295
    );


    drawSign(
      x + 120,
      285
    );
  }


  // ==========================================================
  // ROAD
  // ==========================================================

  fill(ROAD);

  rect(
    0,
    345,
    width,
    110
  );


  // road upper border
  fill(BLACK);

  rect(
    0,
    341,
    width,
    4
  );


  // ==========================================================
  // ROAD LINES
  // ==========================================================

  fill(ROADLINE);

  for (int i = -2; i < 14; i++) {

    float x =
      i * 90
      - (roadOffset % 90);

    rect(
      x,
      395,
      45,
      8
    );
  }


  // ==========================================================
  // CAT
  // ==========================================================

  boolean catFlipped =
    status.equals("BACKWARD") ||
    status.equals("BACK LEFT") ||
    status.equals("BACK RIGHT");


  drawCatFlipped(
    290,
    int(190 + catBob),
    11,
    catFlipped
  );
}


// ============================================================
// STATUS
// ============================================================

void drawStatus() {

  fill(BLACK);

  textSize(28);

  text(
    status,
    width / 2,
    40
  );


  textSize(15);

  if (enabled) {

    text(
      "↑ Forward   ↓ Backward   ← Left   → Right   A Back-Left   D Back-Right",
      width / 2,
      75
    );

    text(
      "Left SHIFT = Spin CCW   Right SHIFT = Spin CW   SPACE = STOP",
      width / 2,
      100
    );

  } else {

    text(
      "SPACE = START",
      width / 2,
      75
    );
  }
}


// ============================================================
// KEY PRESSED
// ============================================================

void keyPressed() {


  // ==========================================================
  // SPACE = START / STOP
  // ==========================================================

  if (key == ' ') {

    if (!spaceHeld) {

      spaceHeld = true;

      enabled = !enabled;


      if (enabled) {

        // START -> immediately forward
        myPort.write('F');

        status = "FORWARD";

      } else {

        myPort.write('S');

        status = "STOP";
      }
    }

    return;
  }


  // STOP state ignores other controls
  if (!enabled) {
    return;
  }


  // ==========================================================
  // A = BACKWARD LEFT
  // ==========================================================

  if (key == 'a' || key == 'A') {

    myPort.write('J');

    status = "BACK LEFT";

    return;
  }


  // ==========================================================
  // D = BACKWARD RIGHT
  // ==========================================================

  if (key == 'd' || key == 'D') {

    myPort.write('K');

    status = "BACK RIGHT";

    return;
  }


  // ==========================================================
  // LEFT SHIFT / RIGHT SHIFT
  // ==========================================================

  if (key == CODED && keyCode == SHIFT) {

    Object nativeEvent = keyEvent.getNative();


    if (nativeEvent instanceof java.awt.event.KeyEvent) {

      java.awt.event.KeyEvent nativeKey =
        (java.awt.event.KeyEvent) nativeEvent;

      int location =
        nativeKey.getKeyLocation();


      // -------------------------------------------------------
      // LEFT SHIFT = COUNTERCLOCKWISE
      // -------------------------------------------------------

      if (
        location ==
        java.awt.event.KeyEvent.KEY_LOCATION_LEFT
      ) {

        // Q is only the serial command sent to Arduino
        myPort.write('Q');

        status = "SPIN CCW";

        return;
      }


      // -------------------------------------------------------
      // RIGHT SHIFT = CLOCKWISE
      // -------------------------------------------------------

      else if (
        location ==
        java.awt.event.KeyEvent.KEY_LOCATION_RIGHT
      ) {

        // P is only the serial command sent to Arduino
        myPort.write('P');

        status = "SPIN CW";

        return;
      }
    }

    return;
  }


  // ==========================================================
  // ARROW KEYS
  // ==========================================================

  if (key == CODED) {


    // --------------------------------------------------------
    // FORWARD
    // --------------------------------------------------------

    if (keyCode == UP) {

      myPort.write('F');

      status = "FORWARD";
    }


    // --------------------------------------------------------
    // BACKWARD
    // --------------------------------------------------------

    else if (keyCode == DOWN) {

      myPort.write('B');

      status = "BACKWARD";
    }


    // --------------------------------------------------------
    // FORWARD LEFT
    // --------------------------------------------------------

    else if (keyCode == LEFT) {

      myPort.write('L');

      status = "LEFT";
    }


    // --------------------------------------------------------
    // FORWARD RIGHT
    // --------------------------------------------------------

    else if (keyCode == RIGHT) {

      myPort.write('R');

      status = "RIGHT";
    }
  }
}


// ============================================================
// KEY RELEASED
// ============================================================

void keyReleased() {


  // ==========================================================
  // SPACE RELEASE
  // ==========================================================

  if (key == ' ') {

    spaceHeld = false;

    return;
  }


  if (!enabled) {
    return;
  }


  // ==========================================================
  // A / D RELEASE -> FORWARD
  // ==========================================================

  if (
    key == 'a' || key == 'A' ||
    key == 'd' || key == 'D'
  ) {

    myPort.write('F');

    status = "FORWARD";

    return;
  }


  // ==========================================================
  // SHIFT RELEASE -> FORWARD
  // ==========================================================

  if (
    key == CODED &&
    keyCode == SHIFT
  ) {

    myPort.write('F');

    status = "FORWARD";

    return;
  }


  // ==========================================================
  // ARROW RELEASE -> FORWARD
  // ==========================================================

  if (key == CODED) {

    if (
      keyCode == UP ||
      keyCode == DOWN ||
      keyCode == LEFT ||
      keyCode == RIGHT
    ) {

      myPort.write('F');

      status = "FORWARD";
    }
  }
}


// ============================================================
// CAT FLIP
//
// SAME CAT.
// NO REDRAW.
// ONLY MIRRORS THE WHOLE EXISTING CAT.
// ============================================================

void drawCatFlipped(
  int x,
  int y,
  int p,
  boolean flipped
) {

  if (!flipped) {

    drawPixelCat(
      x,
      y,
      p
    );

  } else {

    pushMatrix();

    // mirror the entire existing cat
    translate(
      x + 16 * p,
      y
    );

    scale(
      -1,
      1
    );

    drawPixelCat(
      0,
      0,
      p
    );

    popMatrix();
  }
}


// ============================================================
// CAT
// ORIGINAL CAT - UNCHANGED
// ============================================================

void drawPixelCat(int x, int y, int p) {

  // ===================================================
  // SHADOW
  // ===================================================

  fill(SHADOW);

  ellipse(
    x + 5 * p,
    y + 13.3 * p,
    9 * p,
    1.6 * p
  );


  // ===================================================
  // WHISKERS
  // ===================================================

  px(x, y, p, -1, 4, 2, 1, BLACK);
  px(x, y, p, -1, 6, 2, 1, BLACK);

  px(x, y, p, 10, 4, 2, 1, BLACK);
  px(x, y, p, 10, 6, 2, 1, BLACK);


  // ===================================================
  // HEAD
  // ===================================================

  px(x, y, p, 2, 0, 2, 1, BLACK);

  px(x, y, p, 7, 0, 2, 1, BLACK);

  px(x, y, p, 4, 1, 3, 1, BLACK);

  px(x, y, p, 1, 1, 1, 6, BLACK);

  px(x, y, p, 9, 1, 1, 6, BLACK);

  px(x, y, p, 2, 1, 7, 6, WHITE);

  px(x, y, p, 2, 1, 1, 1, PINK);

  px(x, y, p, 8, 1, 1, 1, PINK);

  px(x, y, p, 2, 7, 2, 1, BLACK);

  px(x, y, p, 7, 7, 2, 1, BLACK);


  // ===================================================
  // FACE
  // ===================================================

  px(x, y, p, 3, 4, 1, 1, BLUE);
  px(x, y, p, 4, 4, 1, 1, BLACK);

  px(x, y, p, 6, 4, 1, 1, BLACK);
  px(x, y, p, 7, 4, 1, 1, BLUE);

  px(x, y, p, 5, 5, 1, 1, BLACK);


  // ===================================================
  // BODY
  // ===================================================

  px(x, y, p, 3, 7, 1, 5, BLACK);

  px(x, y, p, 7, 7, 1, 5, BLACK);

  px(x, y, p, 4, 7, 3, 5, WHITE);


  // ===================================================
  // FEET
  // ===================================================

  px(x, y, p, 3, 12, 5, 1, BLACK);

  px(x, y, p, 4, 12, 1, 1, WHITE);

  px(x, y, p, 6, 12, 1, 1, WHITE);


  // ===================================================
  // TAIL
  // ===================================================

  px(x, y, p, 8, 8, 1, 1, BLACK);

  px(x, y, p, 9, 7, 1, 1, BLACK);

  px(x, y, p, 10, 6, 1, 1, BLACK);

  px(x, y, p, 11, 5, 1, 1, BLACK);

  px(x, y, p, 12, 4, 3, 1, BLACK);

  px(x, y, p, 15, 5, 1, 1, BLACK);

  px(x, y, p, 16, 6, 1, 2, BLACK);

  px(x, y, p, 15, 8, 1, 1, BLACK);

  px(x, y, p, 14, 9, 1, 1, BLACK);

  px(x, y, p, 13, 10, 1, 1, BLACK);

  px(x, y, p, 12, 10, 1, 1, BLACK);

  px(x, y, p, 11, 9, 1, 1, BLACK);

  px(x, y, p, 10, 8, 1, 1, BLACK);


  // ===================================================
  // WHITE INSIDE OF TAIL
  // ===================================================

  px(x, y, p, 11, 6, 1, 1, WHITE);

  px(x, y, p, 12, 5, 3, 1, WHITE);

  px(x, y, p, 12, 6, 3, 1, WHITE);

  px(x, y, p, 11, 7, 4, 1, WHITE);

  px(x, y, p, 11, 8, 3, 1, WHITE);

  px(x, y, p, 12, 9, 2, 1, WHITE);
}


// ============================================================
// PIXEL HELPER
// ============================================================

void px(
  int x,
  int y,
  int p,
  int gx,
  int gy,
  int gw,
  int gh,
  color c
) {

  fill(c);

  rect(
    x + gx * p,
    y + gy * p,
    gw * p,
    gh * p
  );
}


// ============================================================
// CACTUS
// ============================================================

void drawCactus(
  float x,
  float y
) {

  fill(BLACK);
  noStroke();

  rect(
    x,
    y,
    8,
    28
  );

  rect(
    x - 8,
    y + 8,
    8,
    8
  );

  rect(
    x - 8,
    y + 16,
    8,
    8
  );

  rect(
    x + 8,
    y + 12,
    8,
    8
  );

  rect(
    x + 8,
    y + 20,
    8,
    8
  );
}


// ============================================================
// SIGN
// ============================================================

void drawSign(
  float x,
  float y
) {

  fill(BLACK);
  noStroke();

  rect(
    x,
    y,
    6,
    40
  );

  rect(
    x - 10,
    y - 14,
    26,
    14
  );
}
