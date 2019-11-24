public class FireDisplay {
  float shotCount; //amount of ammo the tank is to shoot
  int temporaryShotCount; //variable to hold what the tank has shot 
  
  int setpoint; //target position of the firing motor
  long fireEncoderPos; //actual position of the firing motor
  boolean fireFlag; //true if the tank is currently firing
  Button fireToggle; //a button for the UI--tell the tank to fire
  
  PFont font; //font object
  
  int[] colorReleased;
  int[] colorPressed;
  //color arrays for the UI
  
  boolean lastMouse; //last state of the mouse button
  float mouseWheel; //number of rotations of the mouse wheel

  public FireDisplay() {
    shotCount = 1.0;
    colorReleased = new int[3];
    colorPressed = new int[3];
    for (int i = 0; i < 3; i++) {
      colorPressed[i] = 255;
      colorReleased[i] = 150;
    }
    fireToggle = new Button(colorPressed, colorReleased);
    fireToggle.setCoordinates(369, 178, 281, 95);
    font  = createFont("BatmanForeverAlternate", 32);
  }

  public void fireUpdate(boolean[] keys, Console console, long fireEncoderPos) {
    this.update(keys, console, fireEncoderPos);
    //refresh some variables

    textAlign(CENTER, CENTER);
    fill(200);
    textFont(font, 24);
    if (fireEncoderPos > setpoint - 45) text("Ready", 97, 468);
    //if the firing motor has rotated to the setpoint, ready for more
    else text("Firing", 97, 468);

    this.checkCursor();
    textFont(font, 96);
    text(str(floor(shotCount)), 502, 114);
    //display the current amount to be fired

    textFont(font, 78);
    textAlign(CENTER, CENTER);
    fill(200, 0, 0);
    text("Fire", 513, 216);
  }

  private void update(boolean[] keys, Console console, long fireEncoderPos) {
    if (fireFlag && fireEncoderPos > setpoint - 45) {
      //if the firing motor on the tank has moved near the current setpoint 
      console.addToConsole("Tank successfully fired " + temporaryShotCount + " Rubber Bands");
      fireFlag = false;
      //tank is not firing anymore
    }
    if (fireToggle.update(fireEncoderPos > setpoint - 45) || (keys[70] && fireEncoderPos > setpoint - 45)) {
      //if firing button is pressed -OR- the "F" button is pressed, and the tank is ready to fire
      console.addToConsole("Tank is attempting to fire " + floor(shotCount) + " Rubber Bands");
      //display to console
      temporaryShotCount = floor(shotCount); //store the amount wanting to be fired in a variable 
      fireFlag = true; //tank is firing 
      setpoint += 180 * floor(shotCount); // update the setpoint
    }
    else if (keys[32] && fireEncoderPos > setpoint - 45) {
      //if the SPACEBAR is pressed and the tank is ready to fire
      console.addToConsole("Quick Fire: Tank is attempting to fire 1 Rubber Band");
      temporaryShotCount = 1;
      //fire one rubber band
      fireFlag = true; //firing 
      setpoint += 180;
    }
  }

  private void checkCursor() {
    boolean first = (abs(mouseX - 370) < 17) && (abs(mouseY - 125.5) < 19.5); //cursor is on left arrow
    boolean second = (abs(mouseX - 505) < 79) && (abs(mouseY - 121) < 36); //cursor is on number in middle
    boolean third = (abs(mouseX - 612.5) < 17.5) && (abs(mouseY - 125.5) < 19.5); //cursor is on right arrow
    if (first || second || third) fill(255, 255, 255); //if one of these is true, change the number to white
    else fill(200, 200, 200); //otherwise, make it a shade of gray

    if (first && mousePressed && mouseButton == LEFT && !lastMouse) {
      shotCount -= 1; // if the left button is pressed, decrement the shot count
    }

    else if (second) {
      //if the mouse is over the middle number
      shotCount -= mouseWheel/5.0;
      //weird math is to basically decrease the sensitivity of the wheel 
      mouseWheel = 0;
    }
    else if (third && mousePressed && mouseButton == LEFT && !lastMouse) {
      shotCount += 1;
      //if the right button is pressed
    }
    else {
      mouseWheel = 0;
      //if nothing, reset the mouse wheel
    }
    
    shotCount = constrain(shotCount, 1, 12);
    //having the software limit the min and max amount of ammo fired
    
    lastMouse = mousePressed;//updating state variable
  }
  public void updateWheel(float wheel) {
    mouseWheel = wheel;
    //mouse wheel event--update amount that mouse wheel had turned
  }

  public int getSetpoint() {
    return setpoint;
    //get firing motor position
  }
}

