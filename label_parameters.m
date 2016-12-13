function [rewardnum,pennum]=label_parameters(exploration, penalty)
switch exploration.mode
        case 'const'
            mode = 'Constant Epsilon';
            rewardnum=exploration.epsConst;
        case 'decay'
            mode = 'Decaying Epsilon';
            rewardnum=[exploration.epsMax, exploration.epsMin];
        case 'softmax'
            mode = 'Softmax';
            rewardnum=exploration.tempConst;
        case 'softmaxDecay'
            mode = 'Softmax with Decaying Temp';
            rewardnum=[exploration.tempMax, exploration.tempMin];
    end
    switch penalty.Mode
        case 'death'
            penmode = 'Death Penalty';
            pennum=0;
        case 'quad'
            penmode = 'Quadratic Penalty';
            pennum=[penalty.quadMin, penalty.quadMax penalty.quadtrunc];
        case 'const'
            penmode = 'Constant Penalty';
            pennum=penalty.const;
        case 'div'
            penmode = 'Divisive Penalty';
            pennum = penalty.div;
        case 'divconst'
            penmode = 'Divisive Penalty with Constant';
            pennum=[penalty.div, penalty.const];
    end
end