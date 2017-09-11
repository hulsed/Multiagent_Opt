function [obj_opt,x_opt_int,x_opt_cont]= multiagent_opt(funchandle, intchoices,UB,LB,Tol,MaxZones)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT
numKs=100;      % k's are just a way of partitioning evaluations.
numRuns = 10;   % number of runs to test (choose 1 to run a single optimization)
stopEpoch=200;  % Stopping Condition: If objective hasn't improved after this many Epochs 
                % (partitions given by numKs evaluations) stop.
maxEpochs=200;  % Stopping Condition: The max number of partitions to run.
saveWorkspace = 1;          % Saves the workspace in file named 'MASResults'
verbose=1;      % Displays progress in the terminal


showConstraintViolation = 0; %
altplots = 1;



% AGENT PARAMETERS
alpha = 0.005;    % Learning rate for meta-agent (reactiveness)
Meritinit= 1e3;   % Value table initialization--should a bad objective value
rewardstruct='G'; % Exploratory reward structure (G for global, L for local)
                  % it's reccomended to use 'G'.
rewardtype='expImprovement';    %Reward based on simply generating new knowledge
                                % (learned) or the amount generated
                                % (expImprovement)
availabletemps=[0.5,0.1,0.01, 0.005, 0]; % temperatures to be used by sub-agent
availablew1s=[1];   % weights for sub-agent to use for contraints (normalized)
availablew2s=[1];   % weights for sub-agent to use for objective (normalized)
conscalemax=35000;  % max value of constraint over objective (takes place of penalty)
conexp=0.05;        % exponent of scale factor increase
Qinit=1e4;          % table initialization for meta-agent
epsilon=0.05;       % rate of random actions taken by meta-agent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization
% metaagent actions
pq=0
for lm=1:numel(availabletemps)
    for no=1:numel(availablew1s)
        pq=pq+1;
        availableactions(pq,:)=[availabletemps(lm),availablew1s(no),availablew2s(no)]; 
    end
end
% problem parameters
numVars = numel(intchoices)+numel(UB);
numactions=pq*ones(1,numVars);
% The discrete choices for the variables that give best performance
x_opt_int = zeros(numRuns,numel(intchoices));
x_opt_cont = zeros(numRuns,numel(UB));
minobj = Meritinit*zeros(numRuns, 1);

for r = 1:numRuns
    values=create_values(numactions,Qinit); %meta-agent initialization
    % sub-agent initialization
    [expMerit] = create_expfuncs(intchoices,Meritinit); %discrete variables
     meritfxn=init_meritfxn(UB,LB,Tol, Meritinit);      %continuous variables
    [oldptsx,oldptsobj]=init_pts(UB,LB,MaxZones, 0);    
    [oldptsx,oldptscon]=init_pts(UB,LB,MaxZones, 50);
    
    % initializing run performance
    bestobj(1)= Meritinit;      
    bestconviol(1)=Meritinit;
    obj=-10000;
    epochOfMax(r) = 0;
    e=1; 
    converged=false;
    bestobjc=nan(1,maxEpochs);
    avgobjk=nan(1,maxEpochs);
    
    while converged==false
        e=e+1;  %epoch counter
        % store best performance
        bestobj(e)=bestobj(e-1);
        bestconviol(e)=bestconviol(e-1);
        k=0;
        % increase constraint scale factor
        conscale=conscalemax*(1-e^(-conexp*e));
        
        for k=1:numKs
            
            % Meta-agent chooses actions based on learned values
            actions=choose_actions(values, epsilon);
            % actions translated to temperatures and factors
            temps=availableactions(actions,1);
            w1s=availableactions(actions,2);
            w2s=availableactions(actions,3);  
            
            % Sub-agents choose the values of each given design variable
            % integer variables
            tempsi=temps(1:numel(intchoices));
            x_int = choose_paramvals(expMerit, tempsi,w1s,w2s,conscale);
            % continuous variables
            tempsc=temps(numel(intchoices)+1:numel(intchoices)+numel(UB));
            x_cont = choose_continuousparamvals(meritfxn, tempsc,w1s,w2s,conscale);

            % Calculate the objective function of the chosen design. Assign
            % that to the found merit of each paremeter value taken.
             [obj,obj1,conviol]=funchandle(x_int, x_cont);
             intMerit_obj = ones(numel(intchoices), 1) * obj1;
             intMerit_con = ones(numel(intchoices), 1) * conviol;
             
             contMerit_obj = ones(numel(UB), 1) * obj1;
             contMerit_con = ones(numel(UB), 1) * conviol;
            
            % Sub-agent merit update given the objective value calculated.
            % discrete variables
            [expMerit, learnedi,objimprovementi,conimprovementi] = update_merit(expMerit, intMerit_obj, intMerit_con, alpha, x_int, 'best');
            % continuous variables
            [meritfxn,oldptsx,oldptsobj,oldptscon,learnedc,objimprovementc,conimprovementc]=update_continousmerit(oldptsx,oldptsobj,oldptscon,x_cont, contMerit_obj, contMerit_con, UB,LB,Tol,MaxZones, Meritinit);
            
            % Meta-agent rewards and learning
            rewards=calc_rewards([learnedi,learnedc],[objimprovementi,objimprovementc],[conimprovementi,conimprovementc],conscale, rewardtype,rewardstruct);
            values=learn_values(values,actions,rewards,alpha);
            
            % Display optimization progress (if needed)
            if any([learnedi,learnedc])
            learndisp=' learned';
            else
                learndisp='.';
            end 
            if verbose
            disp([num2str(r,'%03.0f') ', ' num2str(e,'%03.0f') ', ' num2str(k,'%03.0f') ', obj=' num2str(obj1, '%+10.2e\n') ', con=' num2str(conviol, '%+10.2e\n') ', min obj=' num2str(bestobj(e), '%+10.2e\n') ', min con=' num2str(bestconviol(e), '%+10.2e\n') ', reward=' num2str(rewards(1)) ])
            end
            
            % Update record of best objective over time
            if conviol < bestconviol(e) 
                bestconviol(e) = conviol;
                % Update record of best actions generated by the system
                x_opt_int(r,:)=x_int;
                x_opt_cont(r,:)=x_cont;
                obj_opt(r)=obj1;
                bestobj(e)=obj1;
            elseif conviol == bestconviol(e)
                if obj1<bestobj(e)
                    x_opt_int(r,:)=x_int;
                    x_opt_cont(r,:)=x_cont;
                    obj_opt(r)=obj1;
                    bestobj(e)=obj1;
                end
            end
        end
        % Stopping conditions
       if e>stopEpoch+1
            if bestobj(e)==bestobj(e-stopEpoch)
                converged=true;
            end
       end
       if e>=maxEpochs
           converged=true;
       end
       
    end
    % store optimization history
    bestobjc(1:length(bestobj))=bestobj;
    bestobjhist(r,:)=bestobjc;
    bestcon(1:length(bestconviol))=bestconviol;
    bestconhist(r,:)=bestcon;
    avgobjhist(r,:)=avgobjk;
    clear bestobj
end

    % generate_plots
    
    % save optimization history in file
    if saveWorkspace ==1
        save('MASResults')
    end

end


