function [G,flightTime,constraints, perf, hover] = calc_G(penalty,scaleFactor, battery, motor, prop, foil, rod)
    
    [perf] = run_qprop(battery, motor, prop, foil);   
    [hover,failure]=find_oper(battery, motor, prop, foil, rod,perf);
    
    % Calculation of Constraints (only possible with performance data) 
        [constraints]=calc_constraints(battery,motor,prop,foil,rod,hover,failure);
  
    % Calculation of Objectives
    totalCost = battery.Cost + motor.Cost*4+4*rod.Cost;
    flightTime = battery.Energy /(4*hover.pelec); %note: power use is for EACH motor.
    
   if failure
        G = 0;
   else
       check=length(constraints);
        switch(penalty.Mode)
            case 'death' %using the death penalty of G=0 for violated constraints
                death=0;
                  for i=1:check
                      
                    if constraints(i)>0
                       death=1;
                    end     
                  end
                  if death
                      G=0;
                  else
                      G=flightTime/scaleFactor;
                  end
            case 'quad' %using the quadratic penalty method.
               for i=1:check
                    if constraints(i)>0
                        conRewards(i)=-penalty.R*constraints(i)^2;
                    else
                        conRewards(i)=0;
                    end     
               end
                G = max(penalty.quadtrunc,(flightTime+sum(conRewards))/scaleFactor); 
            case 'const' %using a constant penalty method
               for i=1:check
                    if constraints(i)>0
                        conRewards(i)=-penalty.const;
                    else
                        conRewards(i)=0;
                    end     
               end
                G = max(penalty.quadtrunc,(flightTime+sum(conRewards))/scaleFactor);
            case 'div' %using a divisive penalty
                for i=1:check
                    if constraints(i)>0
                        conViolation(i)=constraints(i);
                    else
                        conViolation(i)=0;
                    end
                end
                 G=flightTime/(scaleFactor*(1+penalty.div*sum(conViolation)));
               
            case 'divconst'
                for i=1:check
                    if constraints(i)>0
                        conViolation(i)=constraints(i);
                        conRewards(i)=-penalty.const;
                    else
                        conViolation(i)=0;
                        conRewards(i)=0;
                    end
                end
                 G=(flightTime/(1+penalty.div*sum(conViolation))+sum(conRewards(i)))/scaleFactor;
            case 'none'
                G = flightTime/scaleFactor;
        end
   end
     
    


        
        %Note: Truncating possible negative performance to just below zero.
        %This should help with overly high rewards.
end