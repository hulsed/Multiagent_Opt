function uav_plots(maxflightTime, flightTime_hist, maxG, G_hist, useD, AS)
    % I'm sorry this is really messy.

    if useD
        reward = 'D';
    else
        reward = 'G';
    end
    
    switch AS.mode
        case 'const'
            mode = 'Constant Epsilon';
        case 'decay'
            mode = 'Decaying Epsilon';
        case 'softmax'
            mode = 'Softmax';
    end
            
    
    
    figure;
    plot(maxflightTime/60, 'r');
    hold on
    plot(maxG/60, 'k-.', 'LineWidth', 2);
    legend('Max Flight Time (minutes)', 'Max G');
    Title = ['Performance using ' mode ' (' num2str(AS.param1, '%.1f') '), ' reward];
    title(Title)
    xlabel('Run')
    
    figure;
    avgflightTime = mean(flightTime_hist);
%     plot(avgflightTime/60, 'r');
%     hold on
    temp = flightTime_hist(:, 1:10:size(flightTime_hist,2));
    avgTemp = mean(temp);
    error = std(temp/60,0,1) / sqrt(numel(avgTemp));
    errorbar(1:10:size(flightTime_hist,2), avgTemp/60, error, 'r');
    Title = [mode ' (' num2str(AS.param1, '%.1f') '), ' reward];
    title(Title)
    
    Ymax = max(avgflightTime)/60;
    axis([0, numel(avgflightTime), 0, Ymax])
    
    
    hold on
    plot(mean(G_hist)/60);
%     Title = ['Average G using ' mode ' (' num2str(AS.param1, '%.1f') '), ' reward];
%     title(Title)
    xlabel('Epoch')
    legend('Average Flight Time (minutes)', 'Average G')
    Ymax = max(mean(G_hist))/60 * 1.01;
    axis([0, numel(avgflightTime), 0, Ymax])
    
end