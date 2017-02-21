tic % Begin measuring time of execution

clear variables

numKs=50;
numRuns = 10; %Note: D runs slow, so fewer runs is a better idea.
stopEpoch=50; %If it hasn't improved after this many Epochs, stop
maxEpochs=250;
numEpochs=numKs;

Qinit= -10000;
learnmode='best'; %
saveWorkspace = 1;

exploration.biasMin=0.05;
exploration.biasMax=1.0;

% USE THIS TO SELECT WHICH SELECTION POLICY YOU WANT
% Adjust params as necessary, see below for description of each
% myMode = 4;r

scaleFactor=1;      %Note: DO NOT USE
                    %scales reward to not create an infinite probability in
                    %the exponential function of G is on the order of 1000,
                    %increase this to get
                    %Note: for every change to the scale factor, you will
                    %need to change temperature to adjust for the different
                    %reward magnitudes.

% Values for components below are arbitrary. Change as necessary.
% See create_agents.m for details

% BATTERY
batteryAgents = [6, 6, 4];
% MOTOR
motorAgents = [24];
% PROPELLER
propAgents = [7, 12, 10, 10, 15, 15];
% ROD
rodAgents=[4,11,8];
%[4, 16,11,8];

alpha = 0.1; % Learning rate
gamma = 0.1;

% PLOTTING OPTIONS
showMaxFlightTime_vs_MaxG           = 0;
showAvgFlightTime_AvgG_MaxGAchieved = 0;
showJustAvgFlightTime               = 0;
showConstraintViolation             = 0;
showCost                            = 0;
showEnergy                          = 0;
altplots                            =1;


run_experiment;


toc % Return execution time

