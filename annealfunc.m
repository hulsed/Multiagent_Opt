function [xnew] = annealfunc(values,problem);

% BATTERY
batteryAgents = [6, 6, 4];
% MOTOR
motorAgents = [24];
% PROPELLER
propAgents = [7, 12, 10, 10, 15, 15];
% ROD
rodAgents=[4,11,8];
numAgents = numel([batteryAgents motorAgents propAgents rodAgents]);
LB = ones(1,numAgents);   % Lower bound
UB = [batteryAgents motorAgents propAgents rodAgents];  % Upper bound


xnew=values.x;
while 1==1 xnew~=values.x;
xnew=min(UB,max(LB,values.x+stepsizes.*(randi(3,1,length(UB))-2)));
if not(all(isequal(values.x,xnew)));
   break 
end
end

end