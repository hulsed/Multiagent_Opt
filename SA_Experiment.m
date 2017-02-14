% SA Code
% BATTERY
batteryAgents = [6, 6, 4];
% MOTOR
motorAgents = [24];
% PROPELLER
propAgents = [7, 12, 10, 10, 15, 15];
% ROD
rodAgents=[4,11,8];
numAgents = numel([batteryAgents motorAgents propAgents rodAgents]);


ObjectiveFunction = @objcfun;
nvars = numAgents;    % Number of variables
LB = ones(1,numAgents);   % Lower bound
UB = [batteryAgents motorAgents propAgents rodAgents];  % Upper bound
ConstraintFunction = @constfun;
IntCon=1:numAgents;

for a=1:10

for i=1:length(UB)
Xinit(i)=randi(UB(i));
end
%Options.Verbosity=2;
%Options.Generator= @(x) min(max(LB,x+randi(3,1,length(UB))-2),UB);
%Options.InitTemp=1000;
%Options.MaxTries=1000;
%Options.MaxConsRej=2500;
%[x,fval]=anneal(@objcfun, Xinit,Options)

%options = gaoptimset('PlotFcn', @gaplotbestf);
%[x,fval] = ga(ObjectiveFunction,nvars,[],[],[],[],LB,UB, ...
 %   ConstraintFunction,IntCon,options)
 
 % 'InitialTemperature', 500, 'TemperatureFcn', @temperatureboltz,
 soptions=saoptimset('DataType','custom','AnnealingFcn',@annealfunc,'PlotFcn',{@saplotbestf},'InitialTemperature', 600, 'TemperatureFcn', @temperatureboltz, 'StallIterLim',2500) %'reannealinterval', 20)
 [x(a,:),fval(a)]=simulannealbnd(ObjectiveFunction, Xinit,LB, UB,soptions)
 
 namestring=['sa5_' num2str(a) '.fig'];
saveas(gcf, namestring)

end