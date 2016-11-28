% This isn't a function. To use it, first run the main program with desired
% parameters, then use this to see what was going on when the agents picked
% their best combined design.

clear rHist aHist agHist

[~, b] = max(maxG); % b is the run with the overall best design
E = epochOfMax(b); % E is the epoch the best design occured

epoch_range = 5; % how many epochs ahead and behind to inspect

EB = E - epoch_range; % epoch begin
EE = E + epoch_range; % epoch end

if EB < 1
    EB = 1;
end
if EE > numEpochs
    EE = numEpochs;
end

rHist = reshape(rewards_hist(:,b,:), numAgents, numEpochs);
aHist = reshape(actions_hist(:,b,:), numAgents, numEpochs);

agHist = nan(24, EE - EB + 1, numAgents);

temp = agents_hist(b, :);
for ag = 1:numel(agents)
    for ep = EB:EE
        if ep == EB
            agHist(1:numel(agents{ag}), ep-EB+1, ag) = temp{ep}{ag};
        else
            action = aHist(ag, ep);
            agHist(action, ep-EB+1, ag) = temp{ep}{ag}(action);
%             agHist(1:numel(agents{ag}), ep-EB+1, ag) = temp{ep}{ag};
        end
    end
end
% rHist(:, EB:EE)
% aHist(:, EB:EE)