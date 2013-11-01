void loadSummaryData()
{
  
  
    String lines[] = loadStrings("Scenario model_v30 for jayson.csv");
    
    for(int j = 0; j < 6;j++)
    {
      
         int lineNum = 108 + j;
         String []currentLine = lines[lineNum].split(",");
      for(int i= 0; i < 40; i++)
      {
        int rowIndx = i +1;
        summaryValues[j][i] = Float.parseFloat(currentLine[rowIndx]);
      }
    }
}

