public class LightDisplay {
  boolean lightsAuto;
  //true if lights are in automatic mode
  int brightness;
  //return the PWM value of the Lights
  int[] colorReleased;
  int[] colorPressed;
  //colors for the light buttons on the UI
  Button lightsToggle;
  //Button for setting the lights automatic/manual
  
  PFont font;
  //font object
  
  float mouseWheel;
  //rotations of the mouse wheel
  boolean lastMouse;
  boolean lastAutoLightState;
  //storing previous state variables

  public LightDisplay() {
    brightness = 0;
    //initialize to manual mode, with 0 brightness
    
    colorReleased = new int[3];
    colorPressed = new int[3];
    colorReleased[0] = 55;
    colorPressed[0] = 200;
    //creating arrays for color objects 
    lightsToggle = new Button(colorPressed, colorReleased);
    lightsToggle.setCoordinates(32, 178, 281, 95);
    //initialiaing button
    
    font  = createFont("BatmanForeverAlternate", 32);
    //font for the button
  }

  public void lightUpdate(boolean[] keys, Console console) {
    this.update(keys, console);

    textAlign(CENTER, CENTER);
    textFont(font, 32);
    fill(200, 200, 200);
    if (lightsAuto) text("Automatic", 147, 366);
    else text("Manual", 147, 366);

    this.checkCursor();
    textFont(font, 96);
    text(str(brightness), 175, 114);

    fill(200, 200, 200); 
    textFont(font, 24);
    textAlign(CENTER, CENTER);
    fill(200, 200, 200);
    text("Lights Toggle", 168, 207);
    text("Auto/Manual", 169, 234);
  }
  
  private void update(boolean[] keys, Console console) {
    if (lightsToggle.update(true)) {
      lightsAuto = !lightsAuto;
      //if the light toggle button is pressed, invert the light state
      // (manual or automatic)
      if (lightsAuto) console.addToConsole("Lights are now in Automatic Mode");
      //if lights toggled to automatic mode, print this
      else console.addToConsole("Lights are now in Manual Mode, Value: " + brightness);
      //if lights toggled to manual mode, print this and the current brightness
    }
    if (keys[65]) {
      lightsAuto = true;
      //if the "A" key is pressed
    }
    else if (keys[77]) {
      lightsAuto = false;
      //If the "M" key is pressed
    }
  }
  private void checkCursor() {
    boolean first = (abs(mouseX - 42.5) < 17.5) && (abs(mouseY - 125.5) < 19.5); //if cursor is on left arrow
    boolean second = (abs(mouseX - 172.5) < 101.5) && (abs(mouseY - 121) < 36); //if cursor is on number
    boolean third = (abs(mouseX - 308) < 17.5) && (abs(mouseY - 125.5) < 19.5); //if cursor is on right arrow
    
    if (first || second || third) fill(255, 255, 255);
    //if the cursor is on the arrows or the number, fill completely white
    else fill(200, 200, 200);
    //otherwise, fill somewhat grey

    if (first && mousePressed && mouseButton == LEFT && !lastMouse) {
      brightness -= 5;
      //decrease brightness by 5 if the left arrow is pressed
    }

    else if (second) {
      brightness-= mouseWheel;
      mouseWheel = 0;
      //scroll up to increase the brightness, when the cursor is on the number
    }
    else if (third && mousePressed && mouseButton == LEFT && !lastMouse) {
      brightness += 5;
      //increase brightness by 5 if the right arrow is pressed
    }
    else {
      mouseWheel = 0;
      //if none, reset the mouse wheel 
    }
    brightness = constrain(brightness, 0, 100);
    //limit the brightness from 0 to 100
    lastMouse = mousePressed;
    //update state variable
  }
  public void updateWheel(float wheel) {
    mouseWheel = wheel;
    //passing a mouse wheel event
  }
  
  public void printAutoLights(boolean lightState, Console console) {
    //print to the console when low/high level light is detected in automatic
    if(lightsAuto && (lightState !=lastAutoLightState)) {
      //if the tank is in auto and the brightness has changed
      if(lightState) {
        console.addToConsole("Low level light detected- powering on headlamps");
        //if the lights turned on in auto, print this to the console
      }
      else {
        console.addToConsole("Ambient light sufficient- powering off headlamps");
        //if the lights turned off in auto, print this
      }
      lastAutoLightState = lightState;
      //update state variable
    }
  }
  
  public int getBrightness() {
    //return brightness value as a number
    if (lightsAuto) return 999;
    //if it is in auto lights, return 999 (interpreted as auto by tank)
    else return int(map(constrain(brightness, 0, 100), 0, 100, 0, 255));
    //otherwise, scale it to an 8-bit value and return that
  }
}

