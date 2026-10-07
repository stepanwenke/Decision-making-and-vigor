function [l,dl] = k_rho_alpha_ll_wmh(x, a, r, s, b, set_size, K, Z,doprior,fixed_beta)

beta 	  = fixed_beta;            % sensitivity to reward 100 for k and 10 for the data
alpha 	  = 1./(1+exp(-x(1)));     % learning rate
g         = 1./(1+exp(-x(2)));     % lapse rate
bias      = 1./(1+exp(-x(3)));    % positive learning bias
psi       = 1./(1+exp(-x(4)));    % wm decay
rho       = 1./(1+exp(-x(5)));    % wm reliance
%pers       = x(6);    % perserverance
% K needs to be determined

if doprior
    l = -1/2 * (x-Z.mu)'*Z.nui*(x-Z.mu) -  1/2*log(1/det(Z.nui/(2*pi))); %
else
    l = 0;
end

for t=1:length(a)
    
    if isnan(a(t))
        if b(t)==1
            H = ones(set_size(t),3) * 1/3;
            W0 = ones(set_size(t),3) * 1/3; % Starting values for decay
            W = ones(set_size(t),3) * 1/3;
            %kernel = zeros(1,3);
        end
        l=l+0;
    else
        % initialize the values at the start of each block
        if b(t)==1
            H = ones(set_size(t),3) * 1/3;
            W0 = ones(set_size(t),3) * 1/3; % Starting values for decay
            W = ones(set_size(t),3) * 1/3;
            %kernel = zeros(1,3);
        end
        

        % ll choice according wm
        %W = W + pers.*kernel;
        w = W(s(t),:);
        w = beta * w; %+ pers * kernel;
        l0 = max(w);
        la = w(a(t)) - l0 - log(sum(exp(w-l0)));
        p0_wm = exp(la);
        pg_wm = g*p0_wm + (1-g)/3;
        
        wm_w = rho * min(1,K/set_size(t));

        % ll choice according h
        %H = H + pers * kernel;
        h = H(s(t),:);
        h = beta * h; %+ pers * kernel;
        l0 = max(h);
        la = h(a(t)) - l0 - log(sum(exp(h-l0)));
        p0_h = exp(la);
        pg_h = g*p0_h + (1-g)/3;
        

        % Weighing (with lapse rate)
        pg = wm_w * pg_wm + (1 - wm_w) * pg_h;

        % Weighing (without lapse rate)
        %p0 = wm_w * p0_wm + (1 - wm_w) * p0_h;
        
        % Log likelihood
        l = l + log(pg);
        %l = l + log(p0);
        
        % Alphas + Bias     
        if delta > 0
            ef_alpha_h = alpha;
            ef_alpha_wm = 1;
        elseif delta < 0 % when negative RPE you learn less
            ef_alpha_h = (1 - bias) * alpha; % RL alpha attenuated
            ef_alpha_wm = (1 - bias) * 1; % WM alpha stays the same
        end
        
        % Alphas without bias
        % ef_alpha_wm = 1;
        % ef_alpha_h = alpha;

        % RPE
        delta_wm = r(t) - W(s(t),a(t));
        delta_h = 1 - H(s(t),a(t));

         % Alphas + Bias     
        if r(t) == 1
            ef_alpha_h = alpha;
            ef_alpha_wm = 1;
        elseif r(t) == 0 % when negative RPE you learn less
            ef_alpha_h = (1 - bias) * alpha;
            ef_alpha_wm = (1 - bias) * 1;
        end

        % Value updating
        W(s(t),a(t)) = W(s(t),a(t)) + ef_alpha_wm * delta_wm;
        H(s(t),a(t)) = H(s(t),a(t)) + ef_alpha_h * delta_h;
        
        % Forgetting for WM
        W = W + psi*(W0-W);
    
        % Re-set the kernel
        kernel = zeros(1,3);
        kernel(a(t))=1;

        
        
    end
end
l = -l; % NLL




