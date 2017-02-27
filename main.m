tic % Begin measuring time of execution

clear variables

numKs=50;
numRuns = 10; 
stopEpoch=50; %If it hasn't improved after this many Epochs, stop
maxEpochs=250;

Qinit= -10000;
learnmode='best'; %
saveWorkspace = 1;

exploration.biasMin=0.1;
exploration.biasMax=1.0;

%INPUTS: number of choices of each variable
% BATTERY
batteryAgents = [6, 6, 4];
% MOTOR
motorAgents = [24];
% PROPELLER
propAgents = [7, 12, 10, 10, 15, 15];
% ROD
rodAgents=[4,11,8];
varchoices=[batteryAgents motorAgents propAgents rodAgents];

funchandle=@objcfun;

alpha = 0.1; % Learning rate

% PLOTTING OPTIONS
showConstraintViolation             = 0;
altplots                            =1;

run_experiment;

toc % Return execution time

