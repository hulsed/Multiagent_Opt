tic % Begin measuring time of execution

clear variables

numEpochs = 200; % NOTE: Changed generations to epochs because political correctness
numRuns = 20; %Note: D runs slow, so fewer runs is a better idea.
% useD = 0; % 1 - use difference reward, 0 - use global reward
Qinit= 100;
saveWorkspace = 1;

expModes = {'const', 'decay', 'softmax', 'softmaxDecay', 'softmaxAdaptiveExp', 'softmaxAdaptiveLin', 'softmaxFeatScale', 'softmaxSigmoid'};
exploration.epsConst=0.1;
exploration.epsMax=0.5;
exploration.epsMin=0.01;
exploration.decayepsMax=0.5;
exploration.decayepsMin=0.5;
exploration.tempConst=100;
exploration.tempMin=0.01;
exploration.tempMax=10;
exploration.tempMin=10;
exploration.tempMax=50;
exploration.biasMin=0.05;
exploration.biasMax=1.0;
exploration.feasTemp=1;
exploration.feasTempMax=10;
exploration.feasTempMin=1;
exploration.fcMin=0.1;
exploration.fcMax=100;
exploration.feasfactor=3.0; %captures the willingness to explore infeasible actions for a good reward
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
penModes={'const', 'quad', 'div','divconst','death', 'deathplus', 'lin', 'none'};
%choose mode with penMode
penalty.quadMin=100;  %Note: for exponentially decaying penalty, use these to select
penalty.quadMax=100;  %max and min penalty.
penalty.quadtrunc=-100;    % truncated minimum G for the exponential penalty
penalty.const=100;    %Defines constant portion of penalty
penalty.div=10;        %Scale term of penalty for divisive penalty
penalty.death=-100;
penalty.lin=-1000;
penalty.failure=-7000;

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
[batteryData, motorData, propData, foilData, rodData, matData] = load_data('batterytable.csv', ...
    'motortable.csv', 'propranges.csv', 'airfoiltable.csv','rodtable.csv','materialtable.csv');

data.batteryData = batteryData; data.motorData = motorData;
data.propData = propData; data.foilData = foilData; data.rodData = rodData;
data.matData = matData;

% PLOTTING OPTIONS
showMaxFlightTime_vs_MaxG           = 1;
showAvgFlightTime_AvgG_MaxGAchieved = 1;
showJustAvgFlightTime               = 1;
showConstraintViolation             = 1;
showCost                            = 1;
showEnergy                          = 1;
showAvgG                            = 1;

global stateful
for penMode = 8
    for myMode = 8
        for useD = 1
            for stateful = 0
                run_experiment;
            end
        end
    end
end
% WARNING!!!!!!!!!!!!
% After doing the experiments, ALL the figures will come spewing forth
% (maybe)

toc % Spit out execution time

% comment
