function [l,dl] = k_rho_alpha_decay_bias_ll_rlwm(x, a, r, s, b, set_size, K, Z,doprior,fixed_beta)

beta 	  = fixed_beta;            % sensitivity to reward 100 for k and 10 for the data
alpha 	  = 1./(1+exp(-x(1)));     % learning rate
% g         = 1./(1+exp(-x(2)));     % lapse rate
bias      = 1./(1+exp(-x(2)));    % positive learning bias
%psi       = 1./(1+exp(-x(3)));    % wm decay
rho       = 1./(1+exp(-x(3)));    % wm reliance
% K needs to be determined

if doprior
    l = -1/2 * (x-Z.mu)'*Z.nui*(x-Z.mu) -  1/2*log(1/det(Z.nui/(2*pi))); %
else
    l = 0;
end

for t=1:length(a)
    if isnan(a(t))
        if b(t)==1
            Q = ones(set_size(t),3) * 1/3;
            W0 = zeros(set_size(t),3) * 1/3;
            W = ones(set_size(t),3) * 1/3;
        end
        l=l+0;
    else
        % initialize the values at the start of each block
        if b(t)==1
            Q = ones(set_size(t),3) * 1/3;
            W0 = zeros(set_size(t),3) * 1/3;
            W = ones(set_size(t),3) * 1/3;
        end
        
        % ll choice according rl
        q = Q(s(t),:);
        q = beta * q;
        l0 = max(q);
        la = q(a(t)) - l0 - log(sum(exp(q-l0)));
        p0_rl = exp(la);
        %pg_rl = g*p0 + (1-g)/3;
        
        % ll choice according wm
        w = W(s(t),:);
        w = beta * w;
        l0 = max(w);
        la = w(a(t)) - l0 - log(sum(exp(w-l0)));
        p0_wm = exp(la);
        %pg_wm = g*p0 + (1-g)/3;
        
        wm_w = rho * min(1,K/set_size(t));
        
        %pg = wm_w * pg_wm + (1 - wm_w) * pg_rl;
        p0 = wm_w * p0_wm + (1 - wm_w) * p0_rl;
        
        %l = l + log(pg);
        l = l + log(p0);
        
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
        %W = W + psi*(W0-W);
        W(s(t),a(t)) = Wchosen;
    end
end
l = -l; % NLL





