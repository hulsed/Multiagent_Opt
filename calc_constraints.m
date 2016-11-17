function [constraints,conRewards]=calc_constraints(penalty,battery, motor, prop,foil,rod, perf,hoverindex)



%Battery Constraints in a normalized form 1-val/valmax
 %max current
 constraints(1)=1-perf.amps(hoverindex)/battery.Imax;
 %max voltage (satisfied already by the simulation)
 %max power
%Motor Constraint
 %max current
 constraints(2)=1-perf.amps(hoverindex)/battery.Imax;
 %max power
 constraints(3)=1-perf.pelec(hoverindex)/motor.Pmax;
 %max voltage???
%Propeller Constraint
 %Stress under bending
 %Deflection
%Rod Constraint
 %Stress
 %stiffness/natural freq (cantilever beam) (strouhal no=0.2)
 
 %deflection (1% of length, max)
 %impact
 
 %must be long enought that propellers don't interfere
 sepDist=0.25*prop.diameter+prop.diameter;
 motorDist=sepDist/sqrt(2);
 framewidth=0.1; %temp width of frame!
 minRodLength=motorDist-framewidth/2;
 constraints(4)=1-rod.Length/minRodLength;
 
 check=length(constraints);
 for i=1:check
    if constraints(i)>0
        conRewards(i)=-penalty*constraints(i)^2;
    else
        conRewards(i)=0;
    end     
 end
 
 