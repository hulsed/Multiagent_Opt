function [constraints,conRewards]=calc_constraints(penalty,battery, motor, prop, foil, rod, perf, hoverindex)
% Constraints in a normalized form g=val/valmax-1 or g=1-val/valmin
% This means when g<0, constraint is satisfied and when g>0, constraint 
% is violated. When constraints are violated, they are multiplied by the
% penalty to create a negative reward (this works because constraint value
% is negative.)

%Battery 
 %max current
 constraints(1)=(4*perf.amps(hoverindex))/battery.Imax-1; %Note: perf is from EACH motor.
 %max voltage 
 constraints(2)=perf.volts(hoverindex)/battery.Volt-1;
 %max power 
%Motor Constraint
 %max current
 constraints(3)=(perf.amps(hoverindex))/motor.Imax-1;
 %max power
 constraints(4)=(perf.pelec(hoverindex))/motor.Pmax-1;
 %max voltage???
%Propeller Constraint
 %Stress under bending
 %Deflection
%Rod Constraint


 %Stress
 
 %stiffness/natural freq (cantilever beam) (strouhal no=0.2)
 forcedFreq=perf.rpm(hoverindex)/60; %converting to hz
 natFreq=sqrt(rod.Stiffness./(0.5*rod.Mass+motor.Mass))/(2*pi);
 minnatFreq=3*forcedFreq; %natural frequency must be three times the forced frequency.
 % There should be more technical justification for this.
 constraints(5)=1-natFreq/minnatFreq;
 
 %deflection (1% of length, max)
 maxDefl=0.01*rod.Length;
 defl=perf.thrust(hoverindex)/rod.Stiffness;
 constraints(6)=defl/maxDefl-1;
 %impact
 
 %must be long enought that propellers don't interfere
 sepDist=0.25*prop.diameter+prop.diameter;
 motorDist=sepDist/sqrt(2);
 framewidth=0.1; %temp width of frame!
 minRodLength=motorDist-framewidth/2;
 constraints(7)=1-rod.Length/minRodLength;
 
 check=length(constraints);
 for i=1:check
    if constraints(i)>0
        conRewards(i)=-penalty*constraints(i)^2;
    else
        conRewards(i)=0;
    end     
 end
 
 