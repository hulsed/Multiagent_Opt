tic % Begin measuring time of execution

clear variables

numKs=50;
numRuns = 10; %Note: D runs slow, so fewer runs is a better idea.
stopEpoch=50; %If it hasn't improved after this many Epochs, stop
maxEpochs=250;
numEpochs=numKs;
%stopDens=
% useD = 0; % 1 - use difference reward, 0 - use global reward
Qinit= -10000;
learnmode='best'; %
saveWorkspace = 1;

expModes = {'const', 'decay', 'softmax', 'softmaxDecay', 'softmaxAdaptiveExp', 'softmaxAdaptiveLin', 'softmaxFeatScale','softmaxSigmoid'};
exploration.epsConst=0.1;
exploration.epsMax=0.5;
exploration.epsMin=0.01;
exploration.decayepsMax=0.5;
exploration.decayepsMin=0.5;
exploration.tempConst=100;
exploration.tempMin=0.01;
exploration.tempMax=10;
exploration.tempMin=10;
exploration.tempMax=0.01;
exploration.biasMin=0.05;
exploration.biasMax=1.0;
exploration.feasTemp=1;
exploration.feasTempMax=10;
exploration.feasTempMin=1;
exploration.fcMin=0.1;
exploration.fcMax=100;
exploration.feasfactor=0.0; %captures the willingness to explore infeasible actions for a good reward
                          % 1  feasibility and optimality are equally
                          % important
                          % 0  feasibility not important at all
                          % 1+ feasibility is more important than
                          % optimality
                          % So far, 1=20% feasible, 2=40%feasible,
                          % 4=80%feasible (but with some performance
                          % degredation)

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
showConstraintViolation             = 1;
showCost                            = 0;
showEnergy                          = 0;
altplots                            =1;

global stateful
    for myMode = 8
        for useD = 0
            for stateful = 0
                run_experiment;
            end
        end
    end


% WARNING!!!!!!!!!!!!
% After doing the experiments, ALL the figures will come spewing forth
% (maybe)

toc % Spit out execution time

% comment
