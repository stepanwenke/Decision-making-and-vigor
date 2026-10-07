function [choices,rewards] = sim_rlwm(parameters, n_trials, setsize_order_vec, block_index_vec, stimuli_vec, key_pairs_vec, K)
% Inspired from ll_rlwm.m
% This function generates data based on the input in
% rlwm_simulate_data_recoverability.m

% input params
beta 	  = 10;            % sensitivity to reward 
alpha 	  = 1./(1+exp(-parameters(1)));     % learning rate
g         = 1./(1+exp(-parameters(2)));     % lapse rate
bias      = 1./(1+exp(-parameters(3)));    % positive learning bias
psi       = 1./(1+exp(-parameters(4)));    % wm decay
rho       = 1./(1+exp(-parameters(5)));    % wm reliance

% input matrices
set_size = setsize_order_vec; % set size vector
b = block_index_vec; % indicates start of a block with 1
s = stimuli_vec; % stimuli within a set size (from 1 to set_size)
keys = key_pairs_vec; % correct key presses for each trial

% output matrices
a         = zeros(1, n_trials);               % actions
r         = zeros(1, n_trials);               % rewards

% K needs to be determined

for t=1:n_trials
    % if isnan(a(t)) % missed response
    %     % initialize the values at the start of each block 
    %     if b(t)==1 % block number 1
    %         Q = ones(set_size(t),3) * 1/3;
    %         W0 = zeros(set_size(t),3) * 1/3;
    %         W = ones(set_size(t),3) * 1/3;
    %     end
    %     %l=l+0;
    % else % if the response in the trial is recorded in a correct order

    % initialize the values at the start of each block
    if b(t)==1
        Q = ones(set_size(t),3) * 1/3;
        W0 = zeros(set_size(t),3) * 1/3;
        W = ones(set_size(t),3) * 1/3;
    end
    
    % Compute RL-based probability
    q = Q(s(t),:);
    q = beta * q;
    l0 = max(q);

    %la = q(a(t)) - l0 - log(sum(exp(q-l0)));
    la = q - l0 - log(sum(exp(q-l0)));
    p0 = exp(la);
    pg_rl = g*p0 + (1-g)/3;
    
    % Compute WM-based probability
    w = W(s(t),:);
    w = beta * w;
    l0 = max(w);

    %la = w(a(t)) - l0 - log(sum(exp(w-l0)));
    la = w - l0 - log(sum(exp(w-l0)));
    p0 = exp(la);
    pg_wm = g*p0 + (1-g)/3;
    
    % Combine RL and WM
    wm_w = rho * min(1,K/set_size(t));
    pg = wm_w * pg_wm + (1 - wm_w) * pg_rl;
    
    % Simulate choice
    %if rand < max(pg)
    %    action = find(mnrnd(1, pg));  % Multinomial sampling for choice
    %else
    %    action = randi([1, 3]);  % Random choice if not selected by policy
    %end
    %l = l + log(pg);

    action = find(mnrnd(1, pg));  % Multinomial sampling for choice
    
    % Determine if the action is correct based on the condition
    if action == keys(t)
        r(t) = 1;
    else
        r(t) = 0;
    end

    a(t) = action;

    % update the RL and WM weights
    delta = r(t) - Q(s(t),a(t));
    
    if delta > 0
        ef_alpha_rl = alpha;
        ef_alpha_wm = 1;
    elseif delta < 0 % when negative RPE you learn less
        ef_alpha_rl = (1 - bias) * alpha; % RL alpha attenuated
        ef_alpha_wm = (1 - bias) * 1; % WM alpha stays the same
    end
    
    Q(s(t),a(t)) = Q(s(t),a(t)) + ef_alpha_rl * delta;
    Wchosen = W(s(t),a(t)) + ef_alpha_wm *(r(t) - W(s(t),a(t)));
    W = W + psi*(W0-W);
    W(s(t),a(t)) = Wchosen;
    % end
end
%l = -l; % NLL

choices = a;
rewards = r;


