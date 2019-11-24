public class Console {
  //readout for the user
  String[] consoleText;
  //array of text to print out
  PFont font; //font object for console

  public Console() {
    consoleText = new String[4]; //console can hold four lines of text
    font = createFont("BatmanForeverAlternate", 16); //initialize font
    for(int i = 0; i < 4; i++) {
      consoleText[i] = "";
    }
    //create empty strings for the console
  }

  public void addToConsole(String string) {
    //adding a line of text to the console
    boolean internalFlag = false;
    //if we have found an empty spot
    for(int i = 0; i < 4; i++) {
      if(consoleText[i].equals("")) {
        consoleText[i] = string;
        //add the line of text to the empty spot
        internalFlag = true;
        //we found a spot
        break;
      }
    }
    if(!internalFlag){
      //if we didn't find a spot
      for(int i = 1; i < 4; i++) {
        consoleText[i-1] = consoleText[i];
        //shif console text up one
      }
      consoleText[3] = string;
      //add the new text to the last spot
    }
  }
  
  public void displayConsole() {
    //print out the console to the screen
    String displayString = "";
    for(int i = 0; i < 4; i++) {
      displayString += consoleText[i] + '\n';
    }
    textAlign(LEFT, TOP);
    textFont(font, 16);
    fill(200);
    text(displayString, 9, 602);
  }
}

