function [l,dl] = ll_physicalE(x, a, r, Ef, Z,doprior)

beta 	  = exp(x(1));             % sotmax inv temp
k    	  = x(2);     % discount rate
g         = 1/(1+exp(-x(3)));      % lapse rate

if doprior
    l = -1/2 * (x-Z.mu)'*Z.nui*(x-Z.mu) -  1/2*log(1/det(Z.nui/(2*pi))); %
else
    l = 0;
end

for t=1:length(a)
    
    q(1) = r(t) - k*(Ef(t));
    q(2) = 1;
    q = beta * q;
    l0 = max(q);
    la = q(a(t)) - l0 - log(sum(exp(q-l0)));
    p0 = exp(la);
    pg = g*p0 + (1-g)/2;
    l = l + log(pg);
    
end
l = -l;





