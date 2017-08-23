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
propMaxZones=[  5,     5,  5,     5,      5];

% ROD
rodIntChoices=[4];

rodUB=[0.006,0.0380,0.0380];
rodLB=[0.0009,0.0065,0.0065];
rodTol=[0.0001,0.0005,0.0005];
rodMaxZones=[5,5,5];

% ESC
escIntChoices=[6];

% SKID
skidIntChoices=[4];

skidUB=[60,0.0380,0.006];
skidLB=[20,0.0065,0.0009];
skidTol=[1,0.0005,0.0001];
skidMaxZones=[5,5,5];

% Oper

operUB=[30,45];
operLB=[0.1,0.1];
operTol=[1,1];
operMaxZones=[5,5];

Intchoices=[batteryIntChoices motorIntChoices propIntChoices rodIntChoices escIntChoices skidIntChoices];

UB=[propUB,rodUB,skidUB,operUB];
LB=[propLB,rodLB, skidLB,operLB];
Tol=[propTol,rodTol, skidTol,operTol];
MaxZones=[propMaxZones,rodMaxZones, skidMaxZones,operMaxZones];

%add path of model, function
addpath('C:\Projects\GitHub\UAV_MAS_design\QuadrotorModel')
cd('C:\Projects\GitHub\UAV_MAS_design\QuadrotorModel')
addpath('C:\Projects\GitHub\UAV_MAS_design')

funchandle=@objcfun;

[f_opt,x_opt_int,x_opt_cont]=multiagent_opt(funchandle, Intchoices,UB,LB,Tol,MaxZones)

toc % Return execution time

