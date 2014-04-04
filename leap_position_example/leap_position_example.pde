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
String typedText = "";
PrintWriter output;

void setup()
{
  size(16*50, 9*50);
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
  fill(255,0,0);
  textFont(font,18);  
  text(prefix+typedText, 10, height-10);
 
  if (started)
  {
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
      
      fingerPosStrings.append("fx:" + position.getX()+ "\tfy:" +position.getY()+"\n");
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
//    println("fingerPosStrings:"+fingerPosStrings.length());
//    println("toolPosStrings:"+toolPosStrings.length());
    
    if (fingerPosStrings.length() > 0)
    {
      fingerPosStrings.append("****************");
      output.println(fingerPosStrings);
    }
    
    if (toolPosStrings.length()> 0)
    {
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
      typedText = typedText.substring(0,max(0,typedText.length()-1));
      break;
    case TAB:
    case ' ':
    case ESC:
      break;
    case ENTER:
    case RETURN:
//      println("typedText.length:"+typedText.length());
      if (typedText.length() > 0)
      {
        if (!started)//create file
        {
          output = createWriter(typedText);          
        }else {
          output.close();
          typedText = "";
        }
        started = started ? false:true;
      }
      break;
    default:
      typedText += key;
    }
  }
}
