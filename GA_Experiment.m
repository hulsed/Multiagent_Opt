% GA Code
% BATTERY
batteryAgents = [6, 6, 4];
% MOTOR
motorAgents = [24];
% PROPELLER
propAgents = [7, 12, 10, 10, 15, 15];
% ROD
rodAgents=[4,11,8];
numAgents = numel([batteryAgents motorAgents propAgents rodAgents]);


ObjectiveFunction = @objfun;
nvars = numAgents;    % Number of variables
LB = ones(1,numAgents);   % Lower bound
UB = [batteryAgents motorAgents propAgents rodAgents];  % Upper bound
ConstraintFunction = @constfun;
IntCon=1:numAgents;

options = gaoptimset('PlotFcn', @gaplotbestf);
[x,fval] = ga(ObjectiveFunction,nvars,[],[],[],[],LB,UB, ...
    ConstraintFunction,IntCon,options)

