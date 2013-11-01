
import controlP5.*;

ControlP5 cp5;


boolean showCornerValues=false;
int highlightMode = 0;

int POPUP_WIDTH = 170;
int POPUP_HEIGHT = 90;

int GRID_HEIGHT=10;
int GRID_WIDTH=10;

int GRID_DISPLAY_SIZE_X = 700;
int GRID_DISPLAY_SIZE_Y = 700;

int GRID_SIZE_X = GRID_DISPLAY_SIZE_X / GRID_WIDTH;
int GRID_SIZE_Y = GRID_DISPLAY_SIZE_Y / GRID_HEIGHT;

float MAX_CIRCLE_SIZE = (float)GRID_SIZE_X;
float MIN_CIRCLE_SIZE = 2;

float CIRCLE_SIZE_DIFF = MAX_CIRCLE_SIZE - MIN_CIRCLE_SIZE;

int NUM_DAYS = 41;
boolean showUI=true;
int currentDay=0;
float []circleSizes = new float[GRID_HEIGHT*GRID_WIDTH];
float [][]circleTargetSizes = new float[NUM_DAYS][GRID_HEIGHT*GRID_WIDTH];
float []circleSizeSpeed = new float[GRID_HEIGHT*GRID_WIDTH];

OverData [][]overData = new OverData[NUM_DAYS][GRID_HEIGHT*GRID_WIDTH];

int maxSpeed=200;
int frameCounter=0;
int speed = 50;
int nextFrameWait = 50;
Textlabel quarterLabel;
Textlabel pausePlayLabel;
float maxSize;
boolean pause = false;


int mouseOverGridX = -1;
int mouseOverGridY = -1;
PFont popupFont, sideDisplayFont, gridTextFont;

float [][]summaryValues = new float[6][NUM_DAYS];
String [] summaryValueTitles = { "# Infected Cases: ",
                                 "# Infected Villages: ",
                                 "# Special Operations: ",
                                 "# Surveillance: ",
                                 "# Vector Control: ",
                                 "# Active Screenings: "};

float [][]R0Values = new float [40][100];
int [][]CValues  = new int [40][100];


int [][]VCActive = new int[40][100];
int [][]ASActive = new int[40][100];

int [][]option4 = new int[40][100];

int [][]crossTransmission = new int[40][100];
int [][]r0greaterThan1 = new int [40][100];
int [][]specialOperations = new int[40][100];
int [][]surveillancePrevention = new int[40][100];
DropdownList highlightList;

class OverData
{
  float R0base;
  float R0Effectiveness;
  float VCFlyReduction;
  float EffectiveASAttendance;
  
  boolean VCApplied;
  float VCEffectivenessY1Y3;
  float VCEffectivenessY4Y10;
  float ASattendanceY1Y3;
  float ASattendanceY4Y10;  
}

void setup()
{
    size(970,700);
    
    println(GRID_SIZE_Y + " " + GRID_SIZE_Y);
    popupFont = createFont("Helvetica",24);
    sideDisplayFont = createFont("Helvetica",24);
    gridTextFont = createFont("Helvetica",24);
    
  cp5 = new ControlP5(this);
    Controller speedSlider = cp5.addSlider("speed")
     .setPosition(735,50)
     .setRange(0,maxSpeed)
     ;
     PFont p = createFont("Helvetica",20); 
  cp5.setControlFont(p,14);
  Textlabel speedLabel = cp5.addTextlabel("Highlight","Highlight",732,100);
     speedLabel.setColor(color(0,0,0));
     
      pausePlayLabel = cp5.addTextlabel("PlayPause","Playing",732,30);
     pausePlayLabel.setColor(color(0,0,0));
   
     
     highlightList = cp5.addDropdownList("")
          .setPosition(735, 130)
          .setSize(200,100);
          ;
    highlightList.addItem("None",0);
    highlightList.addItem("Cross Transmission",1);
    highlightList.addItem("R0 > 1",2);
    highlightList.addItem("Special Operations",3);
    highlightList.addItem("Surveillance/Prevention",4);
     quarterLabel = cp5.addTextlabel("Current Quarter: 0","Current Quarter: 0",732,5);
     quarterLabel.setColor(color(0,0,0));
     //speedSlider.setColor(new CColor(125,125,125));
     speedSlider.getCaptionLabel().setColor(color(0,0,0));
     speedSlider.setHeight(16);
     
     Controller positionSlider = cp5.addSlider("Position")
     .setPosition(735,70)
     .setRange(0,40)
     ;
     positionSlider.getCaptionLabel().setColor(color(0,0,0));
     positionSlider.setHeight(16);
    loadData();
    loadSummaryData();
    
    for(int i = 0; i < GRID_HEIGHT*GRID_WIDTH;i++)
    {
        circleSizes[i] = circleTargetSizes[currentDay][i];
    }
    setSpeeds(0,1);
    frameRate(25);
    
}

void draw()
{
  
  
  nextFrameWait = maxSpeed-speed;
  if(showUI)
  {
    cp5.show();
  }else
  {
    cp5.hide();
  }
  if(nextFrameWait < 1)
    nextFrameWait = 1;
  background(255);
  smooth();
  frame.setTitle("Quarter: " + currentDay);
  
  noStroke();
  textFont(gridTextFont);
  textSize(11);
  for(int i = 0; i < GRID_HEIGHT*GRID_WIDTH;i++)
  {
      float x = (i % 10) * (GRID_DISPLAY_SIZE_X / GRID_WIDTH)  + GRID_SIZE_X/2;
      float y = (i / 10) * (GRID_DISPLAY_SIZE_Y / GRID_HEIGHT) + GRID_SIZE_Y/2;
      
      
      float sizePercentage = circleSizes[i] / maxSize;
      
      float r = sizePercentage * CIRCLE_SIZE_DIFF + MIN_CIRCLE_SIZE;
      
      // highlight box
      fill(255);
      //println("highlight mode: " + highlightMode);
      if(highlightMode > 0)
      {
          if(highlightMode == 1 && crossTransmission[currentDay][i] > 0)
              fill(255,255,200);  
          else if(highlightMode == 2 && r0greaterThan1[currentDay][i] > 0)
              fill(255,255,200);  
          else if(highlightMode == 3 && specialOperations[currentDay][i] > 0)
              fill(255,255,200);  
          else if(highlightMode == 4 && surveillancePrevention[currentDay][i] > 0)
          {
            println("Setting yellow");
              fill(255,255,200);  
          }
          
          
      }
      rect(x-GRID_SIZE_X/2,y-GRID_SIZE_Y/2,GRID_SIZE_X,GRID_SIZE_Y);
      if( r >= GRID_SIZE_X)
        r=GRID_SIZE_X;
        
      if(r <= MIN_CIRCLE_SIZE)
          r= MIN_CIRCLE_SIZE;
          
       if(circleSizes[i] <1)
         r=0;
        fill(175,0,0);
      ellipse(x,y,r,r); 
      
      if(showCornerValues)
      {
        fill(0);
        text(String.format("%.2g%n", R0Values[currentDay][i]),x - GRID_SIZE_X/2 +2,y - GRID_SIZE_Y/4);
        text(CValues[currentDay][i],x - GRID_SIZE_X/2 +2,y + GRID_SIZE_Y/4 +10);
      }
  }
  
  /*stroke(0);
  strokeWeight(1);
  for(int i = 0; i < GRID_WIDTH;i++)
      line(i * GRID_SIZE_X, 0, i * GRID_SIZE_X, GRID_DISPLAY_SIZE_Y);
  for(int i = 0; i < GRID_HEIGHT;i++)
      line(0, i * GRID_SIZE_Y,GRID_DISPLAY_SIZE_X,i * GRID_SIZE_Y);
  line(GRID_DISPLAY_SIZE_X,0,GRID_DISPLAY_SIZE_X,GRID_DISPLAY_SIZE_Y);
  */
  stroke(0);
  if(mouseOverGridX >= 0 && mouseOverGridY >= 0)
  {
    strokeWeight(3);
    noFill();
    rect(mouseOverGridX * GRID_SIZE_X,mouseOverGridY * GRID_SIZE_Y,GRID_SIZE_X,GRID_SIZE_Y);
    
  }
  
  // Mouse over
  // If mouse is inside window
  
  if(mouseX >=0 && mouseX < GRID_DISPLAY_SIZE_X && mouseY >=0 && mouseY < GRID_DISPLAY_SIZE_Y && pause)
  {
      int xCell = (int) (((float)mouseX / (float)GRID_DISPLAY_SIZE_X)* GRID_WIDTH);
      int yCell = (int) (((float)mouseY / (float)GRID_DISPLAY_SIZE_Y)* GRID_HEIGHT);
      
      drawPopup(xCell,yCell);
      //println(xCell + " " + yCell);
  }
  
  strokeWeight(1);
  fill(0);
  textFont(sideDisplayFont);
  textSize(14);
  for(int i= 0; i < 6; i++)
  {
    text(summaryValueTitles[i] +  (int)summaryValues[i][currentDay], 730,220 + i * 30);
  }
  //println("paused: " + paused);
  for(int i = 0; i < GRID_HEIGHT*GRID_WIDTH;i++)
  {
    if(!pause)
        circleSizes[i] += circleSizeSpeed[i];
  }
    
    
  if(!pause)
    frameCounter++;
  if(frameCounter >= nextFrameWait)
  {
    int nextDay = currentDay+1;
    if(nextDay >= 40)
      nextDay = 0;
    // recalculate size target and speed
    setSpeeds(currentDay,nextDay);
    
    frameCounter=0;
    currentDay = nextDay;
    quarterLabel.setText("Quarter: " + currentDay);
    
  }
  
  
}

void setSpeeds(int currentDay, int nextDay)
{
  for(int i = 0; i < GRID_HEIGHT*GRID_WIDTH;i++)
    {
        circleSizeSpeed[i] = (circleTargetSizes[nextDay][i] - circleTargetSizes[currentDay][i])/ (float)nextFrameWait;
        circleSizes[i] = circleTargetSizes[currentDay][i];
    }
}

void drawPopup(int x, int y)
{
  mouseOverGridX=x;
  mouseOverGridY=y;
  textFont(popupFont);
  textSize(12);
  int indx = y * GRID_WIDTH + x;
  strokeWeight(1);
  fill(125,125,125,200);
  
  rect(mouseX,mouseY,POPUP_WIDTH,POPUP_HEIGHT);
  fill(0);
  text("R0 Base: " + overData[currentDay][indx].R0base,mouseX + 2,mouseY + 20);
  text("R0 vc + as: " + overData[currentDay][indx].R0Effectiveness,mouseX + 2,mouseY + 40);
  text("VC Fly Reduction: " + overData[currentDay][indx].VCFlyReduction,mouseX + 2,mouseY + 60);
  text("Effective 2yr AS: " + overData[currentDay][indx].VCFlyReduction,mouseX + 2,mouseY + 80);
  
  /*
  if(overData[currentDay][indx].VCApplied)
    text("VC Applied: yes",mouseX + 2,mouseY + 40);
  else
    text("VC Applied: no",mouseX + 2,mouseY + 40);
    
  text("VC Effectiveness Y4-Y10: " + overData[currentDay][indx].VCEffectivenessY4Y10,mouseX + 2,mouseY + 80);
  text("AS Attendance Y1-Y3: " + overData[currentDay][indx].ASattendanceY1Y3,mouseX + 2,mouseY + 100);
  text("AS Attendance Y4-Y10: " + overData[currentDay][indx].ASattendanceY4Y10,mouseX + 2,mouseY + 120);*/
  
}
void keyPressed()
{
   if(key=='\t')
      showUI = !showUI;
   if(key==' ')
   {
     pause = !pause; 
     
     println("pause status: " + pause);
     if(pause)
        pausePlayLabel.setText("Paused");
     else
        pausePlayLabel.setText("Playing"); 
    //setPause(pause);
   
   }
}

void setPause(boolean status)
{
    pause = status;
     if(status)
        pausePlayLabel.setText("Paused");
     else
        pausePlayLabel.setText("Playing"); 
}
void controlEvent(ControlEvent theEvent) {
  // if the event is from a group, which is the case with the dropdownlist
  if (theEvent.isGroup()) {
    // if the name of the event is equal to ImageSelect (aka the name of our dropdownlist)
    //if (theEvent.group().name() == "Highlight") {
      // then do stuff, in this case: set the variable selectedImage to the value associated
      // with the item from the dropdownlist (which in this case is either 0 or 1)
     System.out.println("selected: " + theEvent.group().value());
     
     highlightMode = (int)theEvent.group().value();
     
    //}
  } else if(theEvent.name().equals("Position"))
  {
    currentDay=(int)theEvent.value();
    
    if(currentDay >= 40)
      currentDay=39;
    quarterLabel.setText("Quarter: " + currentDay);
    
    int nextDay = currentDay+1;
    if(nextDay>=40)
      nextDay=0;
    setSpeeds(currentDay,nextDay);
  
  }else if(theEvent.isController()) {
    // not used in this sketch, but has to be included
  }
  
}


