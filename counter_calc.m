function [counterfactbattery,counterfactmotor]=counter_calc(batteryAgents, batteryData,motorData)

% creating a counterfactual cell
counterfactcell.Cost=mean(batteryData(:,1));
counterfactcell.Cap=mean(batteryData(:,2))/1000;
counterfactcell.C=mean(batteryData(:,3));
counterfactcell.Mass=mean(batteryData(:,4))/1000;
counterfactcell.Length=mean(batteryData(:,5));
counterfactcell.Width=mean(batteryData(:,6));
counterfactcell.Height=mean(batteryData(:,7));
%creating a counterfactual battery
counterfactbattery.SNum=mean([batteryAgents(2),1]);
counterfactbattery.PNum=mean([batteryAgents(3),1]);
counterfactbattery.TotNum=counterfactbattery.SNum.*counterfactbattery.PNum;
counterfactbattery.Cost=counterfactbattery.TotNum.*counterfactcell.Cost;
counterfactbattery.Mass=counterfactbattery.TotNum.*counterfactcell.Mass;
counterfactbattery.Cap=counterfactcell.Cap*counterfactbattery.PNum;
counterfactbattery.C=counterfactcell.C;
counterfactbattery.Imax=counterfactbattery.C*counterfactbattery.Cap;
counterfactbattery.Volt=4.2*counterfactbattery.SNum;
counterfactbattery.Energy=counterfactbattery.Volt*counterfactbattery.Cap;
% creating a counterfactual motor
counterfactmotor.Kv=mean(motorData(:,1));
counterfactmotor.R0=mean(motorData(:,2))/1000;
counterfactmotor.I0=mean(motorData(:,3));
counterfactmotor.Imax=mean(motorData(:,4));
counterfactmotor.Pmax=mean(motorData(:,5));
counterfactmotor.Mass=mean(motorData(:,6))/1000;
counterfactmotor.Cost=mean(motorData(:,7));
counterfactmotor.Dia=mean(motorData(:,8));