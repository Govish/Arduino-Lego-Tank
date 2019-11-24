#include <digitalWriteFast.h>

#define LIGHT 9
#define PHOTOCELL 19
//LIGHT CONTROL/INTERFACE PINS

#define ENCODERA 3
#define ENCODERB 17
//FIRING MOTOR ENCODER PINS

#define RIGHTPWM 6
#define RIGHTFOR 7
#define RIGHTREV 8
//RIGHT MOTOR PINS

#define LEFTPWM 11
#define LEFTFOR 12
#define LEFTREV 13
//LEFT MOTOR PINS

#define FIREPWM 5
#define FIREFOR 14
#define FIREREV 15
//FIRING MOTOR PINS

int timeout = 1000;
//Comms timeout--if data is not received within this time
//Tank will automatically shut down

String inputString = ""; //for serial data reception
int leftMotor, rightMotor, lightByte; 
//values that hold PWM values for motors and lights

boolean manualFlag, fireFlag;//flags that are related to the lights and Rubber Band Guns (RBGs) respectively

double firingMotor, Output, error, lastError, Setpoint;
int kp = 5;
int kd = 15;
//For the PD controller for the Firing Motor
volatile long encoderPos;// for the firing motor

unsigned long calcTime; //timers for controller calculation, data transmission, and speed calculation;
boolean killFlag; // shut down the tank
unsigned long dataTimeout; //timer during serial transfers
long setpointSubtract; //to store encoder position after serial timeout

void setup() {
  Serial.begin(9600); // initialize serial link with WiFly
  delay(1000);

  pinMode(LIGHT, 1); // setting the light driver as output

  pinMode(RIGHTPWM, 1);
  pinMode(RIGHTFOR, 1);
  pinMode(RIGHTREV, 1);
  //setting motor C ports as outputs

  pinMode(LEFTPWM, 1);
  pinMode(LEFTFOR, 1);
  pinMode(LEFTREV, 1);
  //setting motor A ports as outputs

  attachInterrupt(1, encodeForB, CHANGE);
  //attaching an interrupt for the encoder to read motor position

  pinMode(FIREPWM, 1);
  pinMode(FIREFOR, 1);
  pinMode(FIREREV, 1);
  //setting motor B ports as outputs
}

void encodeForB() {
  if(digitalReadFast(ENCODERA) == digitalReadFast(ENCODERB)) {
    encoderPos++;
  }
  else {
    encoderPos--;
  }
  //A quadrature decoder algorithm with 2x decoding
}

//----------------------------------------------------------------

void compute() {
  //an algorithm to drive the firing motor to a set position
  error = encoderPos - Setpoint;
  Output = constrain(kp * error + kd * (error - lastError), -255, 255);
  //if(abs(Output - 4) < 13) Output = 0;
  lastError = error;
  //constraining the output just to make sure
  if(Output < 0) {
    digitalWrite(FIREFOR, LOW);
    digitalWrite(FIREREV, HIGH);
  }
  else {
    digitalWrite(FIREFOR, HIGH);
    digitalWrite(FIREREV, LOW);
  }
  analogWrite(FIREPWM, constrain(abs(Output), 0, 255));
}

//------------------------------------------------------------------

void output() {
  // a function that will set the pins at the 
  // appropriate state, to correctly drive the motors
  // *note that in the tank, all of the motors are flipped upside-down
  //  so driving the motors forward will make the motor turn "relatively" in reverse
  //  \--when I say that the motor is turning in reverse, I actually mean that it is turning forward

  //-------------- for left motor
  if(leftMotor < 0) {
    digitalWrite(LEFTREV, HIGH);
    digitalWrite(LEFTFOR, LOW);
    // if the output value for left motor is less than 0,
    //set the H-Bridge drive pins to forward
  }
  else {
    digitalWrite(LEFTREV, LOW);
    digitalWrite(LEFTFOR, HIGH);
    //otherwise set the H-Bridge drive pins to reverse
  }
  byte output1 = constrain(abs(leftMotor), 0, 255);
  analogWrite(LEFTPWM, output1);
  //write the PWM value to the enable pins of the h-bridge

  //-------------- for right motor
  if(rightMotor < 0) {
    digitalWrite(RIGHTREV, HIGH);
    digitalWrite(RIGHTFOR, LOW);
    // if the output value for right motor is less than 0,
    //set the H-Bridge drive pins to forward
  }
  else {
    digitalWrite(RIGHTREV, LOW);
    digitalWrite(RIGHTFOR, HIGH);
    //otherwise set the H-Bridge drive pins to reverse

  }
  byte output2 = constrain(abs(rightMotor), 0, 255);
  analogWrite(RIGHTPWM, output2);
  //write the PWM value to the enable pins of the h-bridge


}

void loop() {
  updateVals();
  if(millis() - calcTime > 10) {
    compute();
    calcTime = millis();
  }
  if(millis() - dataTimeout > timeout) {
    //if a serial timeout is detected
    int SHUTDOWN[] = {
      RIGHTFOR, RIGHTREV, RIGHTPWM, LEFTFOR, LEFTREV, LEFTPWM        };
    for(int i = 0; i < 6; i++) {
      digitalWrite(SHUTDOWN[i], HIGH); //drive motors hard brake
    }
    setpointSubtract = encoderPos;
  }
  else {
    //if the time is appropriate for the position to be calcluated
    output();
    //drive the motors

    if(manualFlag) {
      //if the lights are in manual mode, then set the brightness
      //based on the value in lightByte
      analogWrite(LIGHT, lightByte);
    }

    else {
      //if they are in auto, read the voltage on the photocell
      //programmed with a little bit of hysteresis
      if(analogRead(PHOTOCELL) > 850) {
        //if it is dark
        digitalWrite(LIGHT, HIGH);
      }
      else if(analogRead(PHOTOCELL) < 810) {
        //if it is bright
        digitalWrite(LIGHT, LOW);
      }
    }
  }
}

void updateVals() {
  //Get new tank control parameters from the WiFly
  if(Serial.available()) { //if we have data
    dataTimeout = millis(); //reset timeout counter
    char inChar = Serial.read(); //read the byte
    inputString += inChar; //concatenate with input string
    if(inChar == '#' || inChar == '$' || inChar == '\n' || inChar == '^' || inChar == 't') { //if we detect a "tag byte"
      long number = inputString.toInt(); //convert the "Strung" number into a long
      if(inChar == 't') {
        timeout = number; // setting the timeout if we read a 't'
      }
      if(inChar == '#') {
        //if we read a tag that indicates that the previous integer corresponded to the left motor
        //change the input string to an integer (actually a long), sign it, and constrain it
        leftMotor = constrain(number, -255, 255);
      }
      else if(inChar == '$') {
        //if we read a tag that indicates that the previous integer corresponded to the right motor
        //change the input string to an integer (actually a long), sign it, and constrain it
        rightMotor = constrain(number, -255, 255);
      }
      else if(inChar =='^') {
        //if we read a tag that indicates that the previous integer corresponded to the light settings and brightness,
        //change the input string to an integer (actually a long), and constrain it
        //if we read that the lights are in auto mode (indicated by "999"), then set the manual flag to false
        //otherwise set the manual flag to true
        lightByte = constrain(number, 0, 999);
        if(lightByte == 999) {
          manualFlag = false;
        }
        else {
          manualFlag = true;
        }  
      }
      else if(inChar == '\n') {
        //if we read a tag that indicates that the previous integer corresponded to the firing motor
        //change the input string to a double, do some error checking to see if the controller accidentally 
        //reset, and if all is good, load its opposite into the setpoint - see output for more details
        
        //After we receive a newline, we send data from the tank back to the computer
        firingMotor = double(number);

        if(firingMotor > abs(Setpoint - setpointSubtract)) {
          Setpoint = -1 * firingMotor + setpointSubtract; //Rescaling it if the tank reset before
        }
        
        Serial.print(encoderPos - setpointSubtract); //send the firing motor position
        
        if(manualFlag) Serial.println("-"); //if lights are in manual, terminate with a "-"        
        else if(!digitalRead(LIGHT)) Serial.println("0"); //if the light is off in auto, send a "0"
        else if(digitalRead(LIGHT)) Serial.println("1"); //if the light is on in auto, send a "1"
         
      }
      inputString = ""; //clear input string after each parse
    }
  }

}






















