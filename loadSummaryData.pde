void loadSummaryData()
{
  
  
    String lines[] = loadStrings("Scenariovaluesv2.csv");
    
    for(int j = 0; j < 6;j++)
    {
      
         int lineNum = 106 + j;
         String []currentLine = lines[lineNum].split(",");
      for(int i= 0; i < 40; i++)
      {
        int rowIndx = i +1;
        
         option4[j][i] = Integer.parseInt(currentLine[rowIndx]);
      }
    }
}

