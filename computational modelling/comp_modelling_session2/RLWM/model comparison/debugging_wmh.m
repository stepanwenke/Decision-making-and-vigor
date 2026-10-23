% load
load('data_RLWM_retest.mat');

% params
sj=2;


init = rand(1,5);
options=optimset('display','off','DerivativeCheck','on');


a=A(sj,:);
r=R(sj,:);
s=S(sj,:);
b=B(sj,:);
set_size=SetSize(sj,:);

K=3;

%l = k_rho_alpha_ll_wmh(x, a, r, s, b, set_size, K, 0,0,25)

[est,fval,ex]=fminsearch(@(x) k_rho_alpha_ll_wmh(x, a, r, s, b, set_size, K, 0,0,25),init,options)

hess=NumHessian(@(x) k_rho_alpha_ll_wmh(x, a, r, s, b, set_size, K(sj), 0,0,25),est)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

init=rand(1,3);

[est,fval,ex]=fminsearch(@(x) k_rho_alpha_decay_ll_rlwm(x, a, r, s, b, set_size, K(sj), 0,0,25),init,options)

hess=NumHessian(@(x) k_rho_alpha_decay_ll_rlwm(x, a, r, s, b, set_size, K(sj), 0,0,25),est)
