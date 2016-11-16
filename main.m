tic % Begin measuring time of execution

clear variables

numEpochs = 50; % NOTE: Changed generations to epochs because political correctness
numRuns = 25;
useD = 0; % 1 - use difference reward, 0 - use global reward

% Values for components below are arbitrary. Change as necessary.
% See create_agents.m for details

% BATTERY
% 6 choices of lipo cell
% up to 6 serial configurations
% up to 4 parallel configurations
batteryAgents = [6, 6, 4];
% MOTOR
% 24 choices of motor
motorAgents = [24];
% PROPELLER
% 
propAgents = [7, 12, 10, 10, 15, 15];
% ROD
rodAgents=[4, 16,11,8];

accGravity=9.81;

% Value for epsilon-greedy action selection
epsilon = 0.1;
% Learning rate
alpha = 0.1;

[batteryData, motorData, propData, foilData, rodData, matData] = load_data('batterytable.csv', ...
    'motortable.csv', 'propranges.csv', 'airfoiltable.csv','rodtable.csv','materialtable.csv');

% Create counterfactual components
[avgCell, avgMotor, avgProp, avgFoil] = counter_calc(batteryData, ...
    motorData, propData, foilData);

performance = zeros(numRuns, numEpochs);
numAgents = numel([batteryAgents motorAgents propAgents rodAgents]);
% The discrete action choices of the agents that give best performance
bestActions = uint8(zeros(numRuns, numAgents));
% The design parameters resulting from the agents' best actions
bestParams = cell(numRuns);
for r = 1:numRuns
    % Create the agents
    agents = create_agents(batteryAgents, motorAgents, propAgents,rodAgents);

    rewards_hist = zeros(numAgents, numRuns, numEpochs);
    actions_hist = zeros(numAgents, numRuns, numEpochs);

    % The best performance obtained by the team
    maxG = 0;
    for e = 1:numEpochs
        % Have agents choose actions
        actions = choose_actions(agents, epsilon);
        actions_hist(:, r, e) = actions;

        % cell that was chosen, contains data
        temp = batteryData(actions(1), :);
        cell.Cost = temp(1); cell.Cap = temp(2) / 1000; 
        cell.C = temp(3); cell.Mass = temp(4) / 1000;
        % C is C Rating
        battery.sConfigs = double(actions(2)); % number of serial configurations
        battery.pConfigs = double(actions(3)); % number of parallel configurations

        % temp is our motor choice
        temp =  motorData(actions(4), :);
        % For R0, convert to Ohms
        motor.kv = temp(1); motor.R0 = temp(2)/1000; motor.I0 = temp(3);
        motor.Imax = temp(4); motor.Pmax = temp(5); 
        motor.Mass = temp(6) / 1000; motor.Cost = temp(7); motor.Diam = temp(8);

        % Propeller Calculations
        %prop.airfoil = propData(actions(5), 1); % propeller prop.airfoil
        prop.diameter = propData(actions(6), 2)*0.054; % diameter (inch->m)
        prop.angleRoot = propData(actions(7), 3); % blade angle at root
        prop.angleTip = propData(actions(8), 4); % blade angle at tip
        prop.chordRoot = propData(actions(9), 5)*0.054; % chord at root (inch->m)
        prop.chordTip = propData(actions(10), 6)*0.054; % chord at tip (inch->m)

        % Characterizing propeller.
        foil.Cl0=foilData(actions(5),1);
        foil.Cla=foilData(actions(5),2)*360/(2*pi); %converting to 1/deg to 1/rad
        foil.Clmin=foilData(actions(5),3);
        foil.Clmax=foilData(actions(5),4);
        foil.Cd0=foilData(actions(5),5);
        foil.Cd2=foilData(actions(5),6)*360/(2*pi); %converting to 1/deg to 1/rad
        foil.Clcd0=foilData(actions(5),7);
        foil.Reref=foilData(actions(5),8);
        foil.Reexp=foilData(actions(5),9);

        %rod=0; %temp
        mat.Type=actions(11);
        mat.Ymod=matData(actions(11),1); %young's modulus in GPa
        mat.Sut=matData(actions(11),2); %ultimate strength in MPa
        mat.Sy=matData(actions(11),3); %yield strength in MPa
        mat.Dens=matData(actions(11),4); %density in kg/m^3
        mat.Cost=matData(actions(11),5)*(100/2.54)^3; %cost in $/m^3

        rod.mat=mat.Type;
        rod.Ymod=mat.Ymod;
        rod.Sut=mat.Sut;
        rod.Length=rodData(actions(12),1)*2.54/100; %length converted to m
        rod.Dia=rodData(actions(13),2)*2.54/100; %diamenter converted to m
        rod.Thick=rodData(actions(14),3)*2.54/100; %thickness converted to m
        rod.Area=.5*pi*(rod.Dia^2-(rod.Dia-rod.Thick)^2);
        rod.Vol=rod.Length*rod.Area;
        rod.Mass=rod.Vol*mat.Dens; % in kg
        rod.Cost=mat.Cost*rod.Vol;

        % Get rewards for agents and system performance
        [rewards, G] = compute_rewards(useD, cell, battery, motor, prop,...
            foil, rod, avgCell, avgMotor, avgProp, avgFoil);
        rewards_hist(:, r, e) = rewards;

        agents = update_values(agents, rewards, actions, alpha);

        performance(r,e) = G / 60; % convert to seconds
        
        % If this is the best performance encountered so far...
        if G > maxG
            maxG = G;
            % Update record of actions that got us there
            bestActions(r, :) = actions;
            % As well as the parameters that describe the design
            bestParams{r} = {battery, motor, prop, foil};            
        end
    end
end

avgPerf = mean(performance, 1);

toc % Spit out execution time

% comment