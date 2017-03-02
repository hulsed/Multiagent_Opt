tic % Begin measuring time of execution

clear variables

%number of choices of each variable
% BATTERY
batteryChoices = [6, 6, 4];
% MOTOR
motorChoices = [24];
% PROPELLER
propChoices = [7, 12, 10, 10, 15, 15];
% ROD
rodChoices=[4,11,8];
varchoices=[batteryChoices motorChoices propChoices rodChoices];

funchandle=@objcfun;

[bestFoundG,bestActions]=multiagent_opt(funchandle, varchoices);

toc % Return execution time

