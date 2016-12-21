function [constraints]=calc_constraints(battery, motor, prop, foil, rod, hover,failure)
% Constraints in a normalized form g=val/valmax-1 or g=1-val/valmin
% This means when g<0, constraint is satisfied and when g>0, constraint 
% is violated. When constraints are violated, they are multiplied by the
% penalty to create a negative reward (this works because constraint value
% is negative.)

% After typing in constraint, make sure to assign it to a component in
% compute_rewards so it can be learned.
%System
if failure
constraints(1)=10*failure;
constraints(2:8)=0;
else
 constraints(1)=0;
%Battery 
 %max current
 constraints(2)=(4*hover.amps)/battery.Imax-1; %Note: perf is from EACH motor.
 %max voltage 
 constraints(3)=hover.volts/battery.Volt-1;
 %max power 
%Motor Constraint
 %max current
 constraints(4)=hover.amps/motor.Imax-1;
 %max power
 constraints(5)=hover.pelec/motor.Pmax-1;
 %max voltage???
%Propeller Constraint
 %Stress under bending
 %Deflection
%Rod Constraint


 %Stress
 
 %stiffness/natural freq (cantilever beam) (strouhal no=0.2)
 forcedFreq=hover.rpm/60; %converting to hz
 natFreq=sqrt(rod.Stiffness./(0.5*rod.Mass+motor.Mass))/(2*pi);
 minnatFreq=2*forcedFreq; %natural frequency must be two times the forced frequency.
 % There should be more technical justification for this.
 constraints(6)=1-natFreq/minnatFreq;
 
 %deflection (1% of length, max)
 maxDefl=0.01*rod.Length;
 defl=hover.thrust/rod.Stiffness;
 constraints(7)=defl/maxDefl-1;
 %impact
 
 %must be long enought that propellers don't interfere
 sepDist=0.25*prop.diameter+prop.diameter;
 motorDist=sepDist/sqrt(2);
 framewidth=0.1; %temp width of frame!
 minRodLength=motorDist-framewidth/2;
 constraints(8)=1-rod.Length/minRodLength;
 
end
 
 

 
 