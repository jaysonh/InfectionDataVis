void loadData()
{
  String lines[] = loadStrings("data.csv");
  for(int i = 0; i < lines.length;i++)
    {
        if(i >= 2)
        {
            String [] currentLine = lines[i].split(",");
            //println(lines[i]);
            for(int j = 0; j < 41;j++)
            {
              
                circleSizes[j][i-2] = Float.parseFloat(currentLine[j+1]);
                
                
            }
            
            // Now store over data
            overData[i-2] = new OverData();
            overData[i-2].R0base = Float.parseFloat(currentLine[R0BaseIndx]);
            
            if(currentLine[VCAppliedIndx].equals("1"))
              overData[i-2].VCApplied=true;
            else
              overData[i-2].VCApplied=false;
            
            currentLine[VCEffectivenessY1Y3Indx] = currentLine[VCEffectivenessY1Y3Indx].replace('%',' ');
            currentLine[VCEffectivenessY4Y10Indx] =currentLine[VCEffectivenessY4Y10Indx].replace('%',' ');
            currentLine[ASattendanceY1Y3Indx] =currentLine[ASattendanceY1Y3Indx].replace('%',' ');
            currentLine[ASattendanceY4Y10Indx] =currentLine[ASattendanceY4Y10Indx].replace('%',' ');
            
            overData[i-2].VCEffectivenessY1Y3 = Float.parseFloat(currentLine[VCEffectivenessY1Y3Indx]);
            overData[i-2].VCEffectivenessY4Y10 = Float.parseFloat(currentLine[VCEffectivenessY4Y10Indx]);
            overData[i-2].ASattendanceY1Y3 = Float.parseFloat(currentLine[ASattendanceY1Y3Indx]);
            overData[i-2].ASattendanceY4Y10 = Float.parseFloat(currentLine[ASattendanceY4Y10Indx]);
            
            //println(overData[i-2].VCApplied);
        }
    }
    
    // Load R0 data, starting from column 45 row 4
     String fileLines[] = loadStrings("data2.csv");
     
     for(int i = 0; i < 100; i++)
     {
       int lineIndx = i + 3;
       String [] currentLine = fileLines[lineIndx].split(",");
       
       for(int j = 0; j < 40;j++)
       {
           int columnIndx = 45 + j;
           println("i: " + i + " j: " + j + " currentline: " + currentLine[columnIndx]);
           R0Values[j][i] = Float.parseFloat(currentLine[columnIndx]);
       }
     }
     
     // Load C values starting from column 88 row 4
     for(int i = 0; i < 100; i++)
     {
       int lineIndx = i + 3;
       String [] currentLine = fileLines[lineIndx].split(",");
       
       for(int j = 0; j < 40;j++)
       {
           int columnIndx = 87 + j;
           //println("i: " + i + " j: " + j + " currentline: " + currentLine[columnIndx]);
           if(currentLine[columnIndx].equals("#N/A"))
             CValues[j][i] = 0;
           else
             CValues[j][i] = Integer.parseInt(currentLine[columnIndx]);
       }
     }
     
     // Load VC active values starting from column 88 row 4
     for(int i = 0; i < 100; i++)
     {
       int lineIndx = i + 3;
       String [] currentLine = fileLines[lineIndx].split(",");
       
       for(int j = 0; j < 40;j++)
       {
           int columnIndx = 129 + j;
           //println("i: " + i + " j: " + j + " currentline: " + currentLine[columnIndx]);
           if(currentLine[columnIndx].equals("#N/A"))
             VCActive[j][i] = 0;
           else
             VCActive[j][i] = Integer.parseInt(currentLine[columnIndx]);
       }
     }
     
     // Load AS active values starting from column 88 row 4
     for(int i = 0; i < 100; i++)
     {
       int lineIndx = i + 3;
       String [] currentLine = fileLines[lineIndx].split(",");
       
       for(int j = 0; j < 40;j++)
       {
           int columnIndx = 171 + j;
           println("i: " + i + " j: " + j + " currentline: " + currentLine[columnIndx]);
           if(currentLine[columnIndx].equals("#N/A"))
             ASActive[j][i] = 0;
           else
             ASActive[j][i] = Integer.parseInt(currentLine[columnIndx]);
       }
     }
     
}
