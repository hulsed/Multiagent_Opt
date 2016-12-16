tic % Begin measuring time of execution

clear variables

numEpochs = 400; % NOTE: Changed generations to epochs because political correctness
numRuns = 5; %Note: D runs slow, so fewer runs is a better idea.
% useD = 0; % 1 - use difference reward, 0 - use global reward
Qinit= 100;

expModes = {'const', 'decay', 'softmax', 'softmaxDecay', 'softmaxAdaptiveExp', 'softmaxAdaptiveLin', 'softmaxFeatScale'};
exploration.epsConst=0.1;
exploration.decayepsMax=0.5;
exploration.decayepsMin=0.5;
exploration.tempConst=100;
exploration.tempMin=0.01;
exploration.tempMax=10;
exploration.biasMin=0.05;
exploration.biasMax=1;



params = [0.1, 0.5, 100, 100];
% [epsilon, starting epsilon, temp, starting temp ]
%
%good values of t


% USE THIS TO SELECT WHICH SELECTION POLICY YOU WANT
% Adjust params as necessary, see below for description of each
% myMode = 4;r
penModes={'const', 'quad', 'div','divconst','death'};
%choose mode with penMode
penalty.quadMin=100;  %Note: for exponentially decaying penalty, use these to select
penalty.quadMax=100;  %max and min penalty.
penalty.quadtrunc=-1000;    % truncated minimum G for the exponential penalty
penalty.const=100;    %Defines constant portion of penalty
penalty.div=10;        %Scale term of penalty for divisive penalty

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
rodAgents=[4, 16,11,8];

alpha = 0.1; % Learning rate

[batteryData, motorData, propData, foilData, rodData, matData] = load_data('batterytable.csv', ...
    'motortable.csv', 'propranges.csv', 'airfoiltable.csv','rodtable.csv','materialtable.csv');

data.batteryData = batteryData; data.motorData = motorData;
data.propData = propData; data.foilData = foilData; data.rodData = rodData;
data.matData = matData;

penMode=2;
for myMode = 7
    for useD = 1
        run_experiment;
    end
end

% WARNING!!!!!!!!!!!!
% After doing the experiments, ALL the figures will come spewing forth
% (maybe)

toc % Spit out execution time

% comment
