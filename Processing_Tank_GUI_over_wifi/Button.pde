public class Button {
  private int xCoordinate;
  private int yCoordinate;
  //position on screen
  private int wideness;
  private int highness;
  //dimensions
  private int[] colorReleased;
  private int[] colorPressed;
  //colors of the rectangle when pressed and released
  private boolean lastMouse;
  //for detecting mouse clicks
  
  
  public Button(int[] _colorPressed, int[] _colorReleased) {
    colorReleased = _colorReleased;
    colorPressed = _colorPressed;
    //initializing variables
  }
  
  public void setCoordinates(int x, int y, int wide, int high) {
    xCoordinate = x;
    yCoordinate = y;
    wideness = wide;
    highness = high;
    //setting dimensions and position
  }
  
  public boolean update(boolean additionalField) {
    boolean pressFlag = this.pressed() && additionalField;
    //change color if the rectangle is clicked and a passed "additionalField" is true
    //not really good programming practice, but I got lazy
    if(this.held()) {
      fill(colorPressed[0], colorPressed[1], colorPressed[2]);
      //if the left mouse is depressed, change the rectangle color
    }
    else{
      fill(colorReleased[0], colorReleased[1], colorReleased[2]);
      //set the default color of the retangle
    }
    rect(xCoordinate, yCoordinate, wideness, highness, 10);
    //draw the retangle with slightly rounded edges
    return pressFlag;
    //return true if the button was clicked
  }
  
  private boolean pressed() {
    boolean first = (abs(mouseX - (xCoordinate + wideness/2)) < wideness/2) && (abs(mouseY - (yCoordinate + highness/2)) < highness/2);
    //If the cursor is within the rectangle
    boolean second = mousePressed && mouseButton == LEFT && !lastMouse;
    //If the mouse is left-clicked
    lastMouse = mousePressed;
    return first && second; //if the mouse is clicked within the rectangle
  }
  private boolean held() {
    boolean first = (abs(mouseX - (xCoordinate + wideness/2)) < wideness/2) && (abs(mouseY - (yCoordinate + highness/2)) < highness/2);
    //if the cursor is within the rectangle
    boolean second = mousePressed && mouseButton == LEFT;
    //if the left button is being depressed
    return first && second; //return true if both
  }
}

