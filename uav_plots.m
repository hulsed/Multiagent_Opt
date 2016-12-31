    % I'm sorry this is really messy.

    maxflightTime_S = maxflightTime/60;
    flightTime_hist_S = flightTime_hist/60;
    maxG_S = maxG/60;
    G_hist_S = G_hist/60;
    
    if useD
        reward = 'D';
    else
        reward = 'G';
    end
%mode=

    
    
    
%     switch exploration.mode
%         case 'const'
%             mode = 'Constant Epsilon';
%             rewardnum=exploration.epsConst;
%         case 'decay'
%             mode = 'Decaying Epsilon';
%             rewardnum=[exploration.epsMax, exploration.epsMin];
%         case 'softmax'
%             mode = 'Softmax';
%             rewardnum=exploration.tempConst;
%         case 'softmaxDecay'
%             mode = 'Softmax with Decaying Temp';
%             rewardnum=[exploration.tempMax, exploration.tempMin];
%     end
%     switch penalty.Mode
%         case 'death'
%             penmode = 'Death Penalty';
%             pennum=0;
%         case 'quad'
%             penmode = 'Quadratic Penalty';
%             pennum=[penalty.quadMin, penalty.quadMax penalty.quadtrunc];
%         case 'const'
%             penmode = 'Constant Penalty';
%             pennum=penalty.const;
%         case 'div'
%             penmode = 'Divisive Penalty';
%             pennum = penalty.div;
%         case 'divconst'
%             penmode = 'Divisive Penalty with Constant';
%             pennum=[penalty.div, penalty.const];
%     end     
%    
%% Max Flight Time/Max G
if 0
    figure;
    plot(maxflightTime_S, 'r');
    hold on
    plot(maxG_S, 'k-.', 'LineWidth', 2);
    legend('Max Flight Time (minutes)', 'Max G');
    Title = ['Performance using ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', ' num2str(Qinit, '%.1f')];
    title([Title ' ' num2str(stateful)])
    xlabel('Run')
end    
    
%% Avg Flight Time/Avg G + Max G Achieved (1 per run)
    figure;
    plot(mean(G_hist_S), 'LineWidth', 1.25);
%     Title = ['Average G using ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward];
%     title(Title)

    hold on
    plot(epochOfMax, maxG_S, 'o')

    
%     Ymax = max(avgflightTime);
%     axis([0, numel(avgflightTime), 0, Ymax])
    avgflightTime = mean(flightTime_hist_S);
    error = std(flightTime_hist_S,1,1);% / sqrt(size(flightTime_hist_S,1));
    L = size(flightTime_hist_S, 2);
    errorbar(1:10:L, avgflightTime(1:10:L), error(1:10:L), 'r', 'LineWidth', 1);
    Title = [mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', Optimism=' num2str(Qinit, '%.1f')];
    title([Title ' ' num2str(stateful)])
    xlabel('Epoch')
    legend('Max G Achieved', 'Average G', 'Average Flight Time (minutes)', 'Location', 'southeast')
    Ymax = max(maxG_S) * 1.01;
    axis([1, numel(avgflightTime), 0, Ymax])
    %%
    figure; % Plot just average flight time
    errorbar(1:10:L, avgflightTime(1:10:L), error(1:10:L), 'r', 'LineWidth', 1);
    axis([1, numel(avgflightTime), 0, Ymax])
    Title = ['Time in the Air - ' mode ' (' num2str(rewardnum, '%.1f') '), ' reward ', Optimism=' num2str(Qinit, '%.1f')];
    title([Title ' ' num2str(stateful)])
    xlabel('Epoch')
    ylabel('Average Flight Time (minutes)')
    
    %%
    figure; %Plot constraint violation at final epoch       
    bar(median(constraint_hist(:,:,numEpochs)'))
    hold on
    errorbar(1:7, median(constraint_hist(:,:,numEpochs)'),range(constraint_hist(:,:,numEpochs)'), '.')
    Title=['Final Constraint Values, ' penmode ' parameters: ' num2str(pennum)];
    title([Title ' ' num2str(stateful)])