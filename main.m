clear variables

numGenerations = 20;
numRuns = 10;

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
%
accGravity=9.81;

% Value for epsilon-greedy action selection
epsilon = 0.1;

[batteryData, motorData, propData, foilData] = load_data('batterytable.csv', ...
    'motortable.csv', 'propranges.csv', 'airfoiltable.csv');

% Create counterfactual components
[avgCell, avgMotor, avgProp, avgFoil] = counter_calc(batteryData, motorData, propData, foilData);

performance = zeros(numRuns, numGenerations);
finalConverge = uint8(zeros(numRuns, numel([batteryAgents motorAgents propAgents])));

for r = 1:numRuns
    % Create the agents
    agents = create_agents(batteryAgents, motorAgents, propAgents);

    rewards_hist = zeros(numel(agents), numGenerations);
    actions_hist = zeros(numel(agents), numGenerations);



    for g = 1:numGenerations
        % Have agents choose actions
        actions = choose_actions(agents, epsilon);
        actions_hist(:, g) = actions;

        % cell that was chosen, contains data (don't care about vars a b c for
        % now)
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

        disp('computing rewards')
        [rewards, G] = compute_rewards(cell, battery, motor, prop, foil, avgCell, avgMotor, avgProp, avgFoil);
        rewards_hist(:, g) = rewards;

        agents = update_values(agents, rewards, actions, 0.1);

        performance(r,g) = G;
        
    end
    
    finalConverge(r, :) = actions;
    finalParams{r} = {battery, motor};
end

avgPerf = mean(performance, 1);

% comment