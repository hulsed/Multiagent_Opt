function rewards=calc_rewards(learned, objimprovement,conimprovement,conscale, rewardtype, rewardstruct)

expimprovement=objimprovement+conscale*conimprovement.^2;

switch rewardtype
    case 'expImprovement'
        reward=expimprovement;
    case 'learned'
        reward=learned;
    %case 'DiffEst'
    %    reward=DiffEst;
end


switch rewardstruct
    case 'L'
        rewards=reward;
    case 'G'
        rewards=sum(reward)*ones(1,numel(reward));
    case 'D'
        rewards=sum(reward);
end

end