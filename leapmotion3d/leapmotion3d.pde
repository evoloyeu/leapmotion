import java.util.Map;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.ConcurrentHashMap;

import com.leapmotion.leap.Controller;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.Frame;
import com.leapmotion.leap.Hand;
import com.leapmotion.leap.Tool;
import com.leapmotion.leap.Vector;
import com.leapmotion.leap.processing.LeapMotion;

LeapMotion leapMotion;

ConcurrentMap<Integer, Integer> fingerColors;
ConcurrentMap<Integer, Integer> toolColors;
ConcurrentMap<Integer, Vector> fingerPositions;
ConcurrentMap<Integer, Vector> toolPositions;


PFont font;
boolean started = false;
boolean inputDone = false;
String prefix = "Input filename here:";
String hintTxt = prefix;
String promptTxt = "Press ENTER or Return to start record: ";
String typedText = "";
String fbase = "";
String extension = "txt";
String filename = "";
PrintWriter output;

Integer motionCount = 0;
Integer hitCount = 0;

void setup()
{
  size(16*50, 9*50);
  //  size(16*50, 9*50, P3D);
  background(20);
  frameRate(30);
  ellipseMode(CENTER);
  font = createFont("Helvetica", 18);

  leapMotion = new LeapMotion(this);
  fingerColors = new ConcurrentHashMap<Integer, Integer>();
  toolColors = new ConcurrentHashMap<Integer, Integer>();
  fingerPositions = new ConcurrentHashMap<Integer, Vector>();
  toolPositions = new ConcurrentHashMap<Integer, Vector>();
}

void draw()
{
    background(255);
  
    fill(255, 0, 0);
    textFont(font, 18);  
    text(hintTxt, 10, height-5);

    fill(20);
    rect(0, 0, width, height-30);
    StringBuilder fingerPosStrings = new StringBuilder();
    for (Map.Entry entry : fingerPositions.entrySet())
    {
        Integer fingerId = (Integer) entry.getKey();
        Vector position = (Vector) entry.getValue();
        fill(fingerColors.get(fingerId));
        noStroke();
        ellipse(leapMotion.leapToSketchX(position.getX()), leapMotion.leapToSketchY(position.getY()), 24.0, 24.0);
  
        println("x:"+position.getX() + "\ty:"+position.getY() + "\tz:"+position.getZ());      
        fingerPosStrings.append("fx:" + position.getX()+ "\tfy:" +position.getY()+ "\tfz:" +position.getZ()+"\n");
    }    

    StringBuilder toolPosStrings = new StringBuilder();
    for (Map.Entry entry : toolPositions.entrySet())
    {
        Integer toolId = (Integer) entry.getKey();
        Vector position = (Vector) entry.getValue();
        fill(toolColors.get(toolId));
        noStroke();
        ellipse(leapMotion.leapToSketchX(position.getX()), leapMotion.leapToSketchY(position.getY()), 24.0, 24.0);
  
        toolPosStrings.append("tx:" + position.getX()+ "\tty:" +position.getY()+"\n");
    }

    if (fingerPosStrings.length() > 0 && started)
    {
        fingerPosStrings.append("****************frame seperator****************");
        output.println(fingerPosStrings);
    }

    if (toolPosStrings.length()> 0 && started)
    {
        fingerPosStrings.append("****************frame seperator****************");
        output.println(toolPosStrings);
    }
}

void onFrame(final Controller controller)
{
  Frame frame = controller.frame();
  fingerPositions.clear();
  for (Finger finger : frame.fingers())
  {
    int fingerId = finger.id();
    color c = color(random(0, 255), random(0, 255), random(0, 255));
    fingerColors.putIfAbsent(fingerId, c);
    fingerPositions.put(fingerId, finger.tipPosition());
  }
  toolPositions.clear();
  for (Tool tool : frame.tools())
  {
    int toolId = tool.id();
    color c = color(random(0, 255), random(0, 255), random(0, 255));
    toolColors.putIfAbsent(toolId, c);
    toolPositions.put(toolId, tool.tipPosition());
  }
}

void keyReleased() {
  if (key != CODED) {
    switch(key) {
    case BACKSPACE:
    case DELETE:
      typedText = typedText.substring(0, max(0, typedText.length()-1));
      hintTxt = prefix+typedText;
      break;    
    case ESC:
      break;
    case ENTER:
    case RETURN:
    case TAB:
      {
        if (initVariables(typedText))
        {
          typedText = "";                   
          inputDone = true;
          hintTxt = promptTxt+fbase+(hitCount/2+1)+"."+extension;
          hitCount = -1;
        }
        
        if (inputDone)
        {
          recordingControl();
        }       
      }
      break;
    case 'a':case 'A':case 'b':case 'B':case 'c':case 'C':case 'd':case 'D':case 'e':case 'E':
    case 'f':case 'F':case 'g':case 'G':case 'h':case 'H':case 'i':case 'I':case 'j':case 'J':
    case 'k':case 'K':case 'l':case 'L':case 'm':case 'M':case 'n':case 'N':case 'o':case 'O':
    case 'p':case 'P':case 'q':case 'Q':case 'r':case 'R':case 's':case 'S':case 't':case 'T':
    case 'u':case 'U':case 'v':case 'V':case 'w':case 'W':case 'x':case 'X':case 'y':case 'Y':
    case 'z':case 'Z':case ' ':case '0':case '1':case '2':case '3':case '4':case '5':case '6':
    case '7':case '8':case '9':
      typedText += key;
      hintTxt = prefix+typedText;    
    default:
      break;
    }
  }
}

boolean initVariables(String input)
{
  if (input.length() > 0)
  {
    String []elements = input.split("\\s+");
    if (elements.length == 2)
    {
      motionCount = Integer.parseInt(elements[1]);
      String []components = elements[0].split("\\.");
      fbase = components[0];
      if (components.length == 2)
      {
        extension = components[1];
        println("fbase:"+fbase+"\textension:"+extension+"\tmotionCount:"+motionCount);        
      }
      return true;
    }
  }

  return false;
}

void recordingControl()
{
  hitCount++;
  if (hitCount <= motionCount*2 && hitCount > 0)
  {          
    if (hitCount%2 == 1)
    {
      filename = fbase+(hitCount/2+1)+"."+extension;
//      println("filename:"+filename);
      output = createWriter(filename);
      started = true;
      hintTxt = fbase+(hitCount/2+1)+"."+extension +" is recording now; press ENTER to stop"; 
    } else {
      output.close();
      started = false;
      if (hitCount == motionCount*2)
      {
        hintTxt = prefix;
        motionCount = 0;
        hitCount = 0;
        inputDone = false;
      } else {
        hintTxt = promptTxt+fbase+(hitCount/2+1)+"."+extension;
      }
    }
  } else if (hitCount > motionCount){//hitCount >= motionCount
    inputDone = false;
    started = false;
    hintTxt = prefix;
    hitCount = 0;
  }
}
