tic % Begin measuring time of execution

clear variables

%declare the number of choices of each variable
% BATTERY
batteryIntChoices = [6, 7, 4];
% MOTOR
motorIntChoices = [9]; %24 in total, restricting to 9
% PROPELLER
propIntChoices = [7];%, 12, 10, 10, 10, 10];
propUB=         [0.2,   45, 1,      0.02,   1];
propLB=         [0.02,  0,  0,      0.005,  0];
propTol=        [0.002, 1,  0.01,   0.0005, 0.01];
propMaxZones=[  10,     9,  10,     5,      10];

% ROD
rodIntChoices=[4,11,8];
% ESC
escIntChoices=[6];

Intchoices=[batteryIntChoices motorIntChoices propIntChoices rodIntChoices escIntChoices];

UB=propUB;
LB=propLB;
Tol=propTol;
MaxZones=propMaxZones;

%add path of model, function
addpath('C:\Projects\GitHub\UAV_MAS_design\QuadrotorModel')
cd('C:\Projects\GitHub\UAV_MAS_design\QuadrotorModel')
addpath('C:\Projects\GitHub\UAV_MAS_design')

funchandle=@objcfun;

[f_opt,x_opt_int,x_opt_cont]=multiagent_opt(funchandle, Intchoices,UB,LB,Tol,MaxZones)

toc % Return execution time

