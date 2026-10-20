%%%%%%%%%%%%%%%%%
%%% Written by Quentin J. M. Huys, UCL, London 2011
%%% Reference:
%%% Guitart-Masip M, Quentin JM, Fuentemilla LL, Dayan P, Duzel E, Dolan RJ (2012)
%%% Go and no-go learning in reward and punishment: Interaction between affect and effect NeuroImage doi:10.1016/j.neuroimage.2012.04.024

function [choices, reward] = sim_zorowitz (parameters, stimuli_id, go_trials,valence)
beta 	  = exp(parameters(1));            % sensitivity to reward          
alpha 	  = 1./(1+exp(-parameters(2)));     % learning rate
eps       = exp(parameters(3));              % 'pavlovian' parameter. Weigth of Vcue into Qgo
g         = 1/(1+exp(-parameters(4)));          % lapse rate
s         = stimuli_id + 1;                     % stimulus identity (avoid zero because of indexing)
go_tr     = go_trials;
n_trials  = length(go_tr);                        % number of trials
a         = zeros(1, n_trials);               % actions
r         = zeros(1, n_trials);               % rewards
val       = valence;                   % valence

Q=zeros(2,24)+0.5;  % two options for each of 24 robots

% % Assign 1 to val where condition is 0 or 1
% val(c == 1 | c == 2) = 1;
% 
% % Assign 2 to val where condition is 2 or 3
% val(c == 3 | c == 4) = 2;

for t=1:length(a) % trial 1 to the maximum of the action vector which should be equal to number of trials

	q = Q(:,s(t)); 
 

    q(val(t)) = q(val(t)) + eps;    % add Pavlovian effect 

	l0 = q - max(q); % stabilizing so that the highest Q value is 0
	la = l0 - log(sum(exp(l0))); % calculating the soft-max
	p0 = exp(la); % converting log-probabilities back into probabilities
	pg = g*p0 + (1-g)/2; % adjusting for the lapse rate (uniformly over 2 options)
	
    %generate actions
    if pg(1) > rand
        action=1; % go
    else 
        action=2; % no-go
    end
    a(t)=action;

    % Determine if the action is correct based on the condition
    a_correct = false;
    if (go_tr(t) == 1 && action == 1) || (go_tr(t) == 0 && action == 2)
        a_correct = true;
    end
    
    if rand < 0.8
        sham = 0;
    else
        sham = 1;
    end

    % Generate outcomes
    if a_correct % if agent chose the correct option
        if sham == 0 % in 80% cases
%             if val(t) == 1 % win valence
                r(t) = 1;  % reward for correct action in positive valence
        else % in 20% cases
%             if val(t) == 1 % win valence
                r(t) = 0;  % bad luck in positive valence
        end
    else % if agent chose the incorrect option
        if sham == 0 % in 80% cases
%             if val(t) == 1 % win valence
                r(t) = 0;  % punishment for incorrect action in positive valence

        else % in 20% cases
%             if val(t) == 1 % win valence
                r(t) = 1;  % good luck in positive valence
        end
    end
    
    % Update Q-Values
    er = beta * r(t); % val = valence (pos 1 or neg 2); r = reward
	Q(a(t),s(t)) = Q(a(t),s(t)) + alpha * (er - Q(a(t),s(t)));

end


reward = r;
choices = a;


