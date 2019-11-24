import processing.net.*; //network library

Keyboard myKeyboard; //get data from the keyboard
LightDisplay lightDisplay; //display object
FireDisplay fireDisplay; //another display object
Console console; //the console for a status readout
Client client; //a WiFi client
PImage image; //background image for the GUI
PFont font; //font used in GUI

int timeout = 1000; //serial timeout for tank comm fail-safe
boolean[] keys = new boolean[526]; //key status array--if keys are pressed
int[] motors = new int[2]; //array to store values to send to motors
int[] colorPressedFire = new int[3]; //some button color arrays
int[] colorReleasedFire = new int[3]; //same thing
long lasttime; //timer variable

int fireEncoderPos; //positoin of the tank's firing motor

void setup() {
  println("Initializing...");
  try {
    font  = createFont("BatmanForeverAlternate", 32);
    image = loadImage("GUI Background.png");
    size(image.width, image.height);

    myKeyboard = new Keyboard();

    lightDisplay = new LightDisplay();
    console = new Console();
    fireDisplay = new FireDisplay();
    //Initializing GUI and objects

    client = new Client(this, "192.168.1.100", 2000); //create a TCP client

    console.addToConsole("PC Tank Controller");
    console.addToConsole("By Ishaan Govindarajan");
    console.addToConsole("Connected to " + client.ip());
    //Add this text to the console 

    println(); 
    println("Connected to " + client.ip());  
    println();
  }
  catch (Exception e) {
    println("\n\n\n\n Error Initializing"); //if the tank isn't on
    while (true); //hang program
  }
  console.addToConsole("Initialization Successful"); //if all goes well
}

void draw() {
  background(image);

  lightDisplay.lightUpdate(keys, console); 
  //update the GUI for the light interface
  //Send current keyboard status and a console to print text

  fireDisplay.fireUpdate(keys, console, fireEncoderPos); 
  //update the GUI for the shooter display, and send the fire
  //Send key array, a console, and the current position of the firing motor

  myKeyboard.displayBoxKeys(keys);
  //Display the controller input in a box-array thing

  console.displayConsole();
  //print out console text

  motors = myKeyboard.generateSubtractor();
  //get the motor values from the keyboard object

  if (millis() - lasttime > 50) {
    client.write(str(timeout));
    client.write("t");
    client.write(str(motors[0]));
    client.write("#");
    client.write(str(motors[1]));
    client.write("$");
    client.write(str(lightDisplay.getBrightness()));
    client.write("^");
    client.write(str(fireDisplay.getSetpoint()));
    client.write(10); // newline
    lasttime = millis();
  }
  //Send the values to the tank
}

void keyPressed()
{ 
  //key interrupts if something gets pressed
  keys[keyCode] = true;
  //for(int i = 0; i < 526; i++) if(keys[i]) println(str(i));
}

void keyReleased()
{ 
  //key interrupts if something gets released
  keys[keyCode] = false;
}

void mouseWheel(MouseEvent event) {
  //if the mouse wheel is turned
  float e = event.getAmount();
  lightDisplay.updateWheel(e);
  fireDisplay.updateWheel(e);
}

void clientEvent(Client p) { 
  //if we get data back from the tank
  //The firing motor position + the light status
  try {
    String preinputString = (p.readStringUntil(10)); //read until the newline
    String inputString = preinputString.substring(0, preinputString.length() - 3); //take off the newline for the inputString
    fireEncoderPos = abs(Integer.parseInt(inputString)); //convert the firing motor position to an int
    boolean checkLights = boolean(Integer.parseInt(preinputString.substring(preinputString.length() - 3, preinputString.length() - 2)));
    //check the status of the lights
    lightDisplay.printAutoLights(checkLights, console); // send it to the light display object
  }
  catch (Exception e) {
    //cuz i'm lazy :|
    //the checkLights may throw an error
    //Sometimes the parsers throw errors as well
  }
} 

