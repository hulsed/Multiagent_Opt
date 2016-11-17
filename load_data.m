function [batteryData, motorData, propData, foilData,rodData,matData] = ...
         load_data(bCsv, mCsv, pCsv, aCsv,rCsv,matCsv)

    batteryData = csvread(bCsv, 1, 1); %load starting from 2nd row, 2nd col
    motorData = csvread(mCsv, 1, 2, [1, 2, 24, 9]); %load starting from 2nd row, 2nd col
    propData = csvread(pCsv, 1, 0); %load starting from 2nd row
    foilData = csvread(aCsv, 1, 1); %load starting from 2nd row, 2nd col
    rodData= csvread(rCsv,1,0);
    matData=csvread(matCsv,1,1);
end