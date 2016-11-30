% This isn't a function. To use it, first run the main program with desired
% parameters, then use this to see what was going on when the agents picked
% their best combined design.

runToAnalyze=1

if exist('runToAnalyze', 'var')
    if runToAnalyze == 0
        [~, b] = max(maxG); % b is the run with the overall best design
    else
        b = runToAnalyze;
    end
else
    [~, b] = max(maxG); % b is the run with the overall best design
end
clear rHist aHist agHist


E = epochOfMax(b);

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

ftHist = flightTime_hist/60;
% rHist(:, EB:EE)
% aHist(:, EB:EE)

r = runToAnalyze;
%     figure; plotyy(1:1000, ftHist(r, :), 1:1000, aHist(3, :));
figure;
subplot(4,1,[1 2]);
plot(ftHist(r, :), 'r', 'LineWidth', 3);
title('Effect of Design Choices')
ylabel('Flight Time (mins)')
grid on
axis([EB, EE, min(ftHist(r, EB:EE)), max(ftHist(r, EB:EE))])
subplot(4,1,3);
plot(EB:EE, aHist(4, EB:EE), 'm', 'LineWidth', 1.5);

title('Motor Design Choice')
grid on
subplot(4,1,4);
plot(EB:EE, aHist(3, EB:EE), 'k', 'LineWidth', 1.5);
title('Battery Design Choice')
xlabel('Epoch')
grid on

figure;
temp = agents_hist(r, :);

Qvals = zeros(11, 2);
for ep = 1:1000
    Qvals(ep, :) = temp{ep}{3}(2:3);
%             agHist(1:numel(agents{ag}), ep-EB+1, ag) = temp{ep}{ag};
end

plot(Qvals, 'LineWidth', 2);
legend('2 Parallel Configs', '3 Parallel Configs');
xlabel('Epoch')
ylabel('Q value')
title('Value of Agent Actions - Cells in Parallel')

figure;
temp = agents_hist(r, :);

Qvals = zeros(11, 2);
for ep = 1:1000
    Qvals(ep, :) = temp{ep}{4}(14:15);
%             agHist(1:numel(agents{ag}), ep-EB+1, ag) = temp{ep}{ag};
end

plot(Qvals, 'LineWidth', 2);
legend('Motor 14', 'Motor 15');
xlabel('Epoch')
ylabel('Q value')
title('Value of Agent Actions - Choice of Motor')

figure
subplot(2,1,1);
plot(ftHist(r, :), 'r', 'LineWidth', 3);
title('Effect of Rewards')
ylabel('Flight Time (mins)')
grid on
axis([EB, EE, min(ftHist(r, EB:EE)), max(ftHist(r, EB:EE))])
subplot(2,1,2);
plot(rHist(:,EB:EE)')
ylabel('Reward Value for each Component')