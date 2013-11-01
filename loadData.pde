
int R0BaseIndx = 130;
int R0EffectivenessIndx = 173;
int VCFlyReductionIndx = 216;
int EffectiveASAttendanceIndx = 259;

int crossTransmissionIndx = 302;
int r0greaterThan1Indx = 345;
int specialOperationsIndx = 388;
int surveillancePreventionIndx = 431;


int VCAppliedIndx = 46;
int VCEffectivenessY1Y3Indx = 47;
int VCEffectivenessY4Y10Indx = 48;
int ASattendanceY1Y3Indx = 49;
int ASattendanceY4Y10Indx = 50;

void loadData()
{
  //String lines[] = loadStrings("data.csv");
  String lines[] = loadStrings("Scenario model_v30 for jayson.csv");
  
  // Load cases (data that fills circles
  
   maxSize = 0.0f;
  
  for(int i = 0; i < 100;i++)
    {
          int lineIndx = i+4;
            String [] currentLine = lines[lineIndx].split(",");
            //println(lines[i]);
            for(int j = 0; j < 40;j++)
            {
                System.out.println(j+1 + "#" + (i-4));
                circleTargetSizes[j][i] = Float.parseFloat(currentLine[j+1]);
                
                if(circleTargetSizes[j][i] > maxSize)
                  maxSize = circleTargetSizes[j][i];
                
            }
        
    }
    
    
    
    for(int i = 0; i < NUM_DAYS; i++)
    {
      overData[i] = new OverData[GRID_HEIGHT*GRID_WIDTH];
      
      for(int j = 0; j < GRID_HEIGHT*GRID_WIDTH;j++)
      {
            String []currentLine = lines[j+4].split(",");
            
            overData[i][j] = new OverData();
            println((R0BaseIndx+ i) + " " + (j+4) + ": " + currentLine[R0BaseIndx+ i]);
            overData[i][j].R0base = Float.parseFloat(currentLine[R0BaseIndx+ i]);
            overData[i][j].R0Effectiveness = Float.parseFloat(currentLine[R0EffectivenessIndx + i]);
            overData[i][j].VCFlyReduction = Float.parseFloat(currentLine[VCFlyReductionIndx + i].replace('%',' '));
            overData[i][j].EffectiveASAttendance = Float.parseFloat(currentLine[EffectiveASAttendanceIndx + i].replace('%',' '));
            
      }
    }
    // Load data for overlays
     
    
    // Load R0 data and C data, starting from column 45 row 4
     String fileLines[] = loadStrings("Scenario model_v30 for jayson.csv");
     
     for(int i = 0; i < 100; i++)
     {
       int lineIndx = i + 4;
       String [] currentLine = fileLines[lineIndx].split(",");
       
       for(int j = 0; j < 40;j++)
       {
           int columnIndx = 44 + j;
           println("i: " + i + " j: " + j + " currentline: " + currentLine[columnIndx]);
           R0Values[j][i] = Float.parseFloat(currentLine[columnIndx]);
           columnIndx = 86 + j;
           CValues[j][i] = Integer.parseInt(currentLine[columnIndx]);
       }
     }
     
     for(int i = 0; i < 100; i++)
     {
       int lineIndx = i + 4;
       String [] currentLine = fileLines[lineIndx].split(",");
       
       for(int j = 0; j < 40;j++)
       {
           int columnIndx = crossTransmissionIndx + j;
           crossTransmission[j][i] = Integer.parseInt(currentLine[columnIndx]);
           columnIndx = r0greaterThan1Indx + j;
           r0greaterThan1[j][i] = Integer.parseInt(currentLine[columnIndx]);
           columnIndx = specialOperationsIndx + j;
           specialOperations[j][i] = Integer.parseInt(currentLine[columnIndx]);
           columnIndx = surveillancePreventionIndx + j;
           surveillancePrevention[j][i] = Integer.parseInt(currentLine[columnIndx]);
           
       }
     }
}
