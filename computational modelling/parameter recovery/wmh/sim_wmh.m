function [choices,rewards] = sim_wmh(parameters, n_trials, setsize_order_vec, block_index_vec, stimuli_vec, key_pairs_vec, K, fixed_beta)
% Inspired from ll_rlwm.m
% This function generates data based on the input in
% simulate_data_recoverability.m

% input params
beta 	  = fixed_beta;            % sensitivity to reward 
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

    % initialize the values at the start of each block
    if b(t)==1
        H = ones(set_size(t),3) * 1/3;
        W0 = ones(set_size(t),3) * 1/3;
        W = ones(set_size(t),3) * 1/3;
    end
    
    % Compute RL-based probability
    h = H(s(t),:);
    h = beta * h; %+ pers * kernel;
    l0 = max(h);
    %la = h(a(t)) - l0 - log(sum(exp(h-l0)));
    la = h - l0 - log(sum(exp(h-l0)));
    p0_h = exp(la);
    pg_h = g*p0_h + (1-g)/3;
    
    % Compute WM-based probability
    w = W(s(t),:);
    w = beta * w; %+ pers * kernel;
    l0 = max(w);
    %la = w(a(t)) - l0 - log(sum(exp(w-l0)));
    la = w - l0 - log(sum(exp(w-l0)));
    p0_wm = exp(la);
    pg_wm = g*p0_wm + (1-g)/3;
    
    % Set the capacity based on reliance and set size
    wm_w = rho * min(1,K/set_size(t));
    
    % Combine H and WM
    pg = wm_w * pg_wm + (1 - wm_w) * pg_h;
    
    % Simulate choice
    action = find(mnrnd(1, pg));  % Multinomial sampling for choice
    
    % Determine if the action is correct based on the condition
    if action == keys(t)
        r(t) = 1;
    else
        r(t) = 0;
    end

    a(t) = action;

    % update the RL and H weights
    delta_h = 1 - H(s(t),a(t));
    delta_wm = r(t) - W(s(t),a(t));
    
    if r(t) == 1
        ef_alpha_h = alpha;
        ef_alpha_wm = 1;
    elseif r(t) == 0 % when negative RPE you learn less
        ef_alpha_h = (1 - bias) * alpha; % RL alpha attenuated
        ef_alpha_wm = (1 - bias) * 1; % WM alpha stays the same
    end
    
    % Value updating
    W(s(t),a(t)) = W(s(t),a(t)) + ef_alpha_wm * delta_wm;
    H(s(t),a(t)) = H(s(t),a(t)) + ef_alpha_h * delta_h;

    % Forgetting for WM    
    W = W + psi*(W0-W);
    % end
end
%l = -l; % NLL

choices = a;
rewards = r;


