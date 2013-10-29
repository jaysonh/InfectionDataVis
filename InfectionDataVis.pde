
import controlP5.*;

ControlP5 cp5;

int highlightMode = 0;

int POPUP_WIDTH = 170;
int POPUP_HEIGHT = 130;

int GRID_HEIGHT=10;
int GRID_WIDTH=10;

int GRID_DISPLAY_SIZE_X = 500;
int GRID_DISPLAY_SIZE_Y = 500;

int GRID_SIZE_X = GRID_DISPLAY_SIZE_X / GRID_WIDTH;
int GRID_SIZE_Y = GRID_DISPLAY_SIZE_Y / GRID_HEIGHT;

int NUM_DAYS = 41;
boolean showUI=true;
int currentDay=0;
float [][]circleSizes = new float[NUM_DAYS][GRID_HEIGHT*GRID_WIDTH];
OverData []overData = new OverData[GRID_HEIGHT*GRID_WIDTH];

int maxSpeed=200;
int frameCounter=0;
int speed = 50;
int nextFrameWait = 50;
Textlabel quarterLabel;

boolean pause = false;

int R0BaseIndx = 43;
int VCAppliedIndx = 46;
int VCEffectivenessY1Y3Indx = 47;
int VCEffectivenessY4Y10Indx = 48;
int ASattendanceY1Y3Indx = 49;
int ASattendanceY4Y10Indx = 50;

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

float [][]R0Values = new float [41][100];
int [][]CValues  = new int [41][100];
int [][]VCActive = new int[41][100];
int [][]ASActive = new int[41][100];

DropdownList highlightList;

class OverData
{
  float R0base;
  boolean VCApplied;
  float VCEffectivenessY1Y3;
  float VCEffectivenessY4Y10;
  float ASattendanceY1Y3;
  float ASattendanceY4Y10;  
}

void setup()
{
    size(850,500);
    
    
    popupFont = createFont("Helvetica",24);
    sideDisplayFont = createFont("Helvetica",24);
    gridTextFont = createFont("Helvetica",24);
    
  cp5 = new ControlP5(this);
    Controller speedSlider = cp5.addSlider("speed")
     .setPosition(510,10)
     .setRange(0,maxSpeed)
     ;
     
     highlightList = cp5.addDropdownList("highlight")
          .setPosition(510, 30)
          ;
    highlightList.addItem("None",0);
    highlightList.addItem("R0>1",1);
    highlightList.addItem("Active screening active",2);
    highlightList.addItem("Vector control active",3);
    highlightList.addItem("Option 4",4);
     quarterLabel = cp5.addTextlabel("Current Quarter: 0","Current Quarter: 0",20,5);
     quarterLabel.setColor(color(0,0,0));
     //speedSlider.setColor(new CColor(125,125,125));
     speedSlider.getCaptionLabel().setColor(color(0,0,0));
    
    loadData();
    loadSummaryData();
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
      
      float r = circleSizes[currentDay][i];
      
      // highlight box
      fill(255);
      if(highlightMode > 0)
      {
          if(highlightMode == 1 && R0Values[currentDay][i] > 0.0f)
              fill(255,255,200);  
          else if(highlightMode == 2 && ASActive[currentDay][i] > 0)
              fill(255,255,200);  
          else if(highlightMode == 2 && VCActive[currentDay][i] > 0)
              fill(255,255,200);  
          
          
      }
      rect(x-GRID_SIZE_X/2,y-GRID_SIZE_Y/2,GRID_SIZE_X,GRID_SIZE_Y);
      if( r >= GRID_SIZE_X)
        r=GRID_SIZE_X;
        fill(255,0,0);
      ellipse(x,y,r,r); 
      fill(0);
      text(String.format("%.2g%n", R0Values[currentDay][i]),x - GRID_SIZE_X/2 +2,y - GRID_SIZE_Y/4);
      text(CValues[currentDay][i],x - GRID_SIZE_X/2 +2,y + GRID_SIZE_Y/4 +10);
  
  }
  
  stroke(0);
  strokeWeight(1);
  for(int i = 0; i < GRID_WIDTH;i++)
      line(i * GRID_SIZE_X, 0, i * GRID_SIZE_X, GRID_DISPLAY_SIZE_Y);
  for(int i = 0; i < GRID_HEIGHT;i++)
      line(0, i * GRID_SIZE_Y,GRID_DISPLAY_SIZE_X,i * GRID_SIZE_Y);
  line(GRID_DISPLAY_SIZE_X,0,GRID_DISPLAY_SIZE_X,GRID_DISPLAY_SIZE_Y);
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
  textSize(24);
  for(int i= 0; i < 6; i++)
  {
    text(summaryValueTitles[i] +  summaryValues[i][currentDay], 510,120 + i * 40);
  }
  if(!pause)
    frameCounter++;
  if(frameCounter >= nextFrameWait)
  {
    frameCounter=0;
    currentDay++;
    quarterLabel.setText("Quarter: " + currentDay);
    
    if(currentDay >= 41)
    {
      currentDay=0;
    }
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
  text("R0 Base: " + overData[indx].R0base,mouseX + 2,mouseY + 20);
  
  if(overData[indx].VCApplied)
    text("VC Applied: yes",mouseX + 2,mouseY + 40);
  else
    text("VC Applied: no",mouseX + 2,mouseY + 40);
    
  text("VC Effectiveness Y1-Y3: " + overData[indx].VCEffectivenessY1Y3,mouseX + 2,mouseY + 60);
  text("VC Effectiveness Y4-Y10: " + overData[indx].VCEffectivenessY4Y10,mouseX + 2,mouseY + 80);
  text("AS Attendance Y1-Y3: " + overData[indx].ASattendanceY1Y3,mouseX + 2,mouseY + 100);
  text("AS Attendance Y4-Y10: " + overData[indx].ASattendanceY4Y10,mouseX + 2,mouseY + 120);
  
}
void keyPressed()
{
   if(key=='\t')
      showUI = !showUI;
   if(key==' ')
     pause = !pause;  
}

void controlEvent(ControlEvent theEvent) {
  // if the event is from a group, which is the case with the dropdownlist
  if (theEvent.isGroup()) {
    // if the name of the event is equal to ImageSelect (aka the name of our dropdownlist)
    if (theEvent.group().name() == "highlight") {
      // then do stuff, in this case: set the variable selectedImage to the value associated
      // with the item from the dropdownlist (which in this case is either 0 or 1)
     //System.out.println("selected: " + theEvent.group().value());
     
     highlightMode = (int)theEvent.group().value();
     
    }
  } else if(theEvent.isController()) {
    // not used in this sketch, but has to be included
  }
}


