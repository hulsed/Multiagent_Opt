function [G,flightTime,climbEnergy, constraints, hover] = calc_G(penalty,scaleFactor, battery, motor, prop, foil, rod, sys)
    
    failure=0;
    climbFailure=0;
    %write files for qprop
    write_propfile(prop,foil);
%     MEXTEST(motor.R0, motor.I0, motor.kv);
    
    %[perf] = run_qprop(battery, motor, prop, foil);   
    %[hover,failure]=find_oper(battery, motor, prop, foil, rod,perf);
    %hover
    [hover] = calc_hover(sys);

    
    %max climbing velocity
    %maxv=calc_maxv(sys);
    %climb
    [climbEnergy,climbFailure] = calc_maxclimb(sys,battery,motor);
    %steady flight
    
    %Calculation to find out if any of the objective failed
    if isnan(hover.pelec)
        failure=1;
    elseif hover.failure==1
        failure=1;
    elseif climbFailure==1
        failure=1;
    end
    % Calculation of Constraints (only possible with performance data) 
        [constraints]=calc_constraints(battery,motor,prop,foil,rod,sys,hover,failure);
  
    % Calculation of Objectives
    totalCost = battery.Cost + motor.Cost*4+4*rod.Cost;
    flightTime = battery.Energy /(4*hover.pelec); %note: power use is for EACH motor.
    
    %Adding Objectives together...
    multiObjective=flightTime-climbEnergy/100;
    
   if failure
        G = penalty.failure;
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
                      G=penalty.death;
                  else
                      G=(multiObjective)/scaleFactor;
                  end
            case 'deathplus'
                  death=0;
                    for i=1:check
                        if constraints(i)>0
                            death=1;
                            conRewards(i)=penalty.lin*constraints(i);
                        else
                            conRewards(i)=0;
                        end 
                    end
                         
                  if death
                      G=penalty.death+sum(conRewards);
                  else
                      G=(multiObjective)/scaleFactor;
                  end
            case 'quad' %using the quadratic penalty method.
               for i=1:check
                    if constraints(i)>0
                        conRewards(i)=-penalty.R*(1+constraints(i))^2;
                    else
                        conRewards(i)=0;
                    end     
               end
                G = max(penalty.quadtrunc,((multiObjective)+sum(conRewards))/scaleFactor); 
            case 'const' %using a constant penalty method
               for i=1:check
                    if constraints(i)>0
                        conRewards(i)=-penalty.const;
                    else
                        conRewards(i)=0;
                    end     
               end
                G = max(penalty.quadtrunc,((multiObjective)+sum(conRewards))/scaleFactor);
            case 'div' %using a divisive penalty
                for i=1:check
                    if constraints(i)>0
                        conViolation(i)=constraints(i);
                    else
                        conViolation(i)=0;
                    end
                end
                 G=(multiObjective)/(scaleFactor*(1+penalty.div*sum(conViolation)));
               
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
                 G=((multiObjective)/(1+penalty.div*sum(conViolation))+sum(conRewards(i)))/scaleFactor;
            case 'lin';
                for i=1:check
                    if constraints(i)>0
                        conRewards(i)=penalty.lin*constraints(i)-100;
                    else
                        conRewards(i)=0;
                    end     
               end
                G = ((multiObjective)+sum(conRewards))/scaleFactor; 
            case 'none'
                G = (multiObjective)/scaleFactor;
        end
   end
     
    


        
        %Note: Truncating possible negative performance to just below zero.
        %This should help with overly high rewards.
end