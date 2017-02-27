
% _S suffix means SCALED
%maxflightTime_S = maxflightTime/60;
%flightTime_hist_S = flightTime_hist/60;
%maxG_S = maxG/60;
%G_hist_S = G_hist/60;

%% Constraint Violation
if showConstraintViolation
    figure; %Plot constraint violation at final epoch       
    medconst=median(bestConstraints(:,:))
    bar(medconst)
    
    hold on
    neg=medconst-min(bestConstraints(:,:));
    pos=max(bestConstraints(:,:))-medconst;
    errorbar([1:8],medconst,neg,pos, '.')

    Title=['Constraint Values of converged designs'];
    title(Title)
    xlabel('Constraint Number')
    ylabel('Value')
end

if altplots
    figure;

    
    %avgbest=mean(bestGhist);
    medbest=nanmedian(bestGhist);
    neg=medbest-min(bestGhist);
    pos=max(bestGhist)-medbest;
    
    for r=1:numRuns
        for h=1:length(medbest)
            if ~isnan(bestGhist(r,h))
                endptx(r)=h;
                endpty(r)=bestGhist(r,h);
            end
            if ~isnan(medbest(h))
                graphend=h;
             end
        end
    end
    endpt=[endptx;endpty];
    for r=1:numRuns
            numdup{r}=sum(endptx(r)==endptx);
    end
    % Plot line without errorbars. Contains all points.
    plot(1:graphend, medbest(1:graphend), 'k')
    hold on
    L = size(medbest, 2);
    x = [1 10:10:L];
    % Plot errorbar about every 10 points
    % NOTE: Must go into plot editor thing to remove line without removing
    % error bars
    errorbar(x, medbest(x),neg(x),pos(x), 'k')
    %errorbar([1:graphend], medbest(1:graphend),neg(1:graphend),pos(1:graphend))
    Title=['Agent Optimization Over ' num2str(numRuns) ' runs'];
    title(Title)
    xlabel('Learning Cycles')
    ylabel('Performance G')
    xlim([0,graphend])
    ylim([0.25*min(min(bestGhist)),1.1*max(max(bestGhist))])
    plot(endptx, endpty, 'o', 'color','r')
    grid on
    grid minor
    %for r=1:numRuns
    %    text(endptx(r), endpty(r),num2str(numdup{r}))
    %end
figure;
boxplot(endpty, 'orientation', 'horizontal')
% axis([900,2300, 0.9, 1.1])
title('Best values found by each run')

grid on
grid minor
   
end

hold off 
