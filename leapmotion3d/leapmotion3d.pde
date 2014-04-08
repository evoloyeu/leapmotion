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
String prefix = "Input filename here:";
String hintTxt = prefix;
String promptTxt = "Press ENTER or Return to start record: ";
String typedText = "";
String fbase = "";
String extension = "";
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
  if (!started)
  {
    fill(255, 0, 0);
    textFont(font, 18);  
    text(hintTxt, 10, height-10);

  } else {
    fill(20);
    rect(0, 0, width, height);
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

    if (fingerPosStrings.length() > 0)
    {
      fingerPosStrings.append("****************frame seperator****************");
      output.println(fingerPosStrings);
    }

    if (toolPosStrings.length()> 0)
    {
      fingerPosStrings.append("****************frame seperator****************");
      output.println(toolPosStrings);
    }
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
      break;
      //    case TAB:    
    case ESC:
      break;
    case ENTER:
    case RETURN:
    case TAB:
      {
        if (initVariables(typedText))
        {          
          started = true;
          hitCount = 0;
        }
        
        typedText = "";
        
        hitCount++;
        if (hitCount <= motionCount*2)
        {          
          if (hitCount%2 == 1)
          {
            filename = fbase+(hitCount/2+1)+"."+extension;
            println("filename:"+filename);
            output = createWriter(filename);
            started = true;
          } else {
            output.close();
            started = false;
            if (hitCount == motionCount*2)
            {
              hintTxt = prefix;
              motionCount = 0;
            } else {
              hintTxt = promptTxt+fbase+(hitCount/2+1)+"."+extension;
            }
          }
        } else {//hitCount >= motionCount
          started = false;
          hintTxt = prefix;
        }        
      }
      break;
    default:
      typedText += key;
      hintTxt = prefix+typedText;
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
      if (components.length == 2)
      {
        fbase = components[0];
        extension = components[1];
        println("fbase:"+fbase+"\textension:"+extension+"\tmotionCount:"+motionCount);
        return true;
      }
    }
  }

  return false;
}

