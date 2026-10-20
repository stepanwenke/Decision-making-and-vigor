function [choices] = sim_physicalE(parameters, effort_level, stake, n_trials)

    beta = exp(parameters(1));            % Softmax inverse temperature
    k = 1./(1+exp(-parameters(2)));                    % Discount rate
    g   = 1./(1+exp(-parameters(3)));     % lapse rate

    e = effort_level;
    s = stake;

    choices = zeros(1, n_trials); % Initialize choices

    for t = 1:n_trials
        % Calculate Q-values
        q(1) = s(t) - k * (e(t))^2; % Q-value for choosing effort
        q(2) = 1;                   % Q-value for not choosing effort (fixed reward 1)

        % Apply softmax to Q-values to get action probabilities
        q = beta * q;
        l0 = max(q);
        exp_q = exp(q - l0); % Normalize to avoid numerical issues
        pa = exp_q / sum(exp_q); % Action probabilities

        % Combine model-based with lapse (uniform random choice)
        pg = g * pa + (1 - g) * 0.5;

        % Simulate choice based on action probabilities
        choices(t) = pg(1) > rand; % 1 if effort chosen, 0 otherwise

        
    end   
end
