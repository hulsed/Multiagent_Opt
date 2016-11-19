function [avgCell, avgMotor, avgProp, avgFoil, avgRod] ...
    = counter_calc(batteryData, motorData, propData, foilData, rodData, matData)

% creating a counterfactual cell
avgCell.Cost=mean(batteryData(:,1));
avgCell.Cap=mean(batteryData(:,2))/1000;
avgCell.C=mean(batteryData(:,3));
avgCell.Mass=mean(batteryData(:,4))/1000;
avgCell.Length=mean(batteryData(:,5));
avgCell.Width=mean(batteryData(:,6));
avgCell.Height=mean(batteryData(:,7));
%creating a counterfactual battery
% counterfactbattery.SNum=mean([batteryAgents(2),1]);
% counterfactbattery.PNum=mean([batteryAgents(3),1]);
% counterfactbattery.TotNum=counterfactbattery.SNum.*counterfactbattery.PNum;
% counterfactbattery.Cost=counterfactbattery.TotNum.*counterfactcell.Cost;
% counterfactbattery.Mass=counterfactbattery.TotNum.*counterfactcell.Mass;
% counterfactbattery.Cap=counterfactcell.Cap*counterfactbattery.PNum;
% counterfactbattery.C=counterfactcell.C;
% counterfactbattery.Imax=counterfactbattery.C*counterfactbattery.Cap;
% counterfactbattery.Volt=4.2*counterfactbattery.SNum;
% counterfactbattery.Energy=counterfactbattery.Volt*counterfactbattery.Cap;
% creating a counterfactual motor
avgMotor.kv=mean(motorData(:,1));
avgMotor.R0=mean(motorData(:,2))/1000;
avgMotor.I0=mean(motorData(:,3));
avgMotor.Imax=mean(motorData(:,4));
avgMotor.Pmax=mean(motorData(:,5));
avgMotor.Mass=mean(motorData(:,6))/1000;
avgMotor.Cost=mean(motorData(:,7));
avgMotor.Dia=mean(motorData(:,8));

% creating counterfact prop
avgProp.diameter = mean(propData(:, 2)*0.054); % diameter (inch->m)
avgProp.angleRoot = mean(propData(:, 3)); % blade angle at root
avgProp.angleTip = mean(propData(:, 4)); % blade angle at tip
avgProp.chordRoot = mean(propData(:, 5)*0.054); % chord at root (inch->m)
avgProp.chordTip = mean(propData(:, 6)*0.054); % chord at tip (inch->m)

% creating counterfactual foil
avgFoil.Cl0=mean(foilData(:,1));
avgFoil.Cla=mean(foilData(:,2)*360/(2*pi)); %converting to 1/deg to 1/rad
avgFoil.Clmin=mean(foilData(:,3));
avgFoil.Clmax=mean(foilData(:,4));
avgFoil.Cd0=mean(foilData(:,5));
avgFoil.Cd2=mean(foilData(:,6)*360/(2*pi)); %converting to 1/deg to 1/rad
avgFoil.Clcd0=mean(foilData(:,7));
avgFoil.Reref=mean(foilData(:,8));
avgFoil.Reexp=mean(foilData(:,9));

% Average Rod Stewart
avgMat.Ymod=mean(matData(:,1)); %young's modulus in GPa
avgMat.Sut=mean(matData(:,2)); %ultimate strength in MPa
avgMat.Sy=mean(matData(:,3)); %yield strength in MPa
avgMat.Dens=mean(matData(:,4)); %density in kg/m^3
avgMat.Cost=mean(matData(:,5))*(100/2.54)^3; %cost in $/m^3

avgRod.mat = avgMat; % Struct avgRod has property mat containing struct
avgRod.Length=mean(rodData(:,1))*2.54/100; %length converted to m
avgRod.Dia=mean(rodData(:,2))*2.54/100; %diamenter converted to m
avgRod.Thick=mean(rodData(:,3))*2.54/100; %thickness converted to m
% avgRod.Area=.5*pi*(avgRod.Dia^2-(avgRod.Dia-avgRod.Thick)^2);
% avgRod.Vol=avgRod.Length*avgRod.Area;
% avgRod.Mass=avgRod.Vol*avgMat.Dens; % in kg
% avgRod.Cost=avgMat.Cost*avgRod.Vol;