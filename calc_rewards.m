function rewards=calc_rewards(learned,rewardtype)

switch rewardtype
    case 'L'
        rewards=learned;
    case 'G'
        rewards=sum(learned)*ones(1,numel(learned));
end

end