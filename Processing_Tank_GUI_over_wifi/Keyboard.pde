public class Keyboard {
  private int topBottom; //stores forward/backward arrow states in int format
  private int leftRight; //stores left/right arrow states in int format
  private int[] fill = new int[9]; // for the controller input GUI-- fill for the rectangles
  
  public Keyboard() {
    //nothing in the constructor
  }
  
  public void displayBoxKeys(boolean[] keys) {
    boolean leftArrow = keys[37];
    boolean upArrow = keys[38];
    boolean rightArrow = keys[39];
    boolean downArrow = keys[40];
    //updating various arrow key states
    
    if(upArrow && downArrow) {
      topBottom = 1;
      //if both top and bottom are pressed, do nothing
    }
    
    else if(upArrow) topBottom = 0;   //forward
    else if(downArrow) topBottom = 2; //back
    else topBottom = 1;//default
    //this is all for some fancy graphics array
    
    if(leftArrow && rightArrow) {
      leftRight = 1;
    }
    else if(leftArrow) leftRight = 0;
    else if(rightArrow) leftRight = 2;
    else leftRight = 1;
    //same sort of thing for the left-right "axis"
    
    drawBoxes();
    //draw the controller GUI
  }
  
  private void drawBoxes() {
    int data = 3 * topBottom + leftRight;
    //the current direction of the tank
    //box which corresponds to the arrows that are depressed is highlighted
    
    for(int i = 0; i < 9;i++) {
      fill[i] = 55;
      //reset the square colors
    }
    fill[data] = 200; // set the one square brighter than the others
    
    for(int i = 0; i < 3; i++) {
      //go down
      for(int j = 0; j < 3; j++) {
        //go across
        fill(fill[3 * i + j], 0, 0);
        rect((j * 55) + 466, (i * 55) + 320, 50, 50);
        //draw the boxes based on the position of the array
      }
    }      
  }
  
  public int[] generateSubtractor() {
    int[] motors = new int[2]; //left motor and right motor
    
    int throttle = (topBottom-1) * -255; //throttle generated from up/down arrows-scaled to 8-bit
    int steering = (leftRight-1) * -255; //steering generated from right/left arrows-scaled to 8-bit
    
    motors[0] = constrain(throttle + steering, -255, 255);
    motors[1] = constrain(throttle - steering, -255, 255);
    //Generating the virtual subtractor drive; example:
    //http://sariel.pl/2012/10/nxt-virtual-subtractor/#more-2413
   
    return motors; //return array
  }
}

