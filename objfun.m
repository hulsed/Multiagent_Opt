function obj=objfun(actions)
    %if ~isequal(actions,lastactions)
     %Residual parameters of the design
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
    penalty.Mode='none';

scaleFactor=1;      %Note: DO NOT USE
                    %scales reward to not create an infinite probability in
                    %the exponential function of G is on the order of 1000,
                    %increase this to get
                    %Note: for every change to the scale factor, you will
                    %need to change temperature to adjust for the different
                    %reward magnitudes.
                    [batteryData, motorData, propData, foilData, rodData, matData] = load_data('batterytable.csv', ...
    'motortable.csv', 'propranges.csv', 'airfoiltable.csv','rodtable.csv','materialtable.csv');

data.batteryData = batteryData; data.motorData = motorData;
data.propData = propData; data.foilData = foilData; data.rodData = rodData;
data.matData = matData;
     
                    
                    
                    
        res.mass=0.3;
        res.framewidth=0.075; %temp width of frame!
        res.planArea=res.framewidth^2;
        res.cost=50;
        res.power=5;
        %design of system and subsystems
        motorNum = actions(4); % remember motor number so we can get the right motorfile
        battery = design_battery(actions, batteryData);
        motor = design_motor(actions, motorData);
        [prop,foil] = design_prop(actions, propData, foilData);
        rod = design_rod(actions, rodData, matData, prop,res);
        sys=design_sys(battery, motor, prop, foil, rod, res, motorNum);
       
        [G,Objectives, constraints, hover] = calc_G(penalty,scaleFactor,...
            battery, motor, prop, foil, rod, sys);
        
        %end
    obj=-G;
end


