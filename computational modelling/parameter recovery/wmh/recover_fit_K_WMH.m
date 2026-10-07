function recover_fit_K_WMH(sj,f)
parpool('local', 16);

% Measure time
fprintf("START: %s\n", datestr(now, 'yyyy-mm-dd HH:MM:SS'));
t0 = tic;

% fit_subject - fits RLWM model for one subject, one model
%
% sj : subject index
% f  : model index (corresponds to ff{f})

% -------------------------
% Load data
load('output/synthdata_WMH_pilot2.mat');

% -------------------------
% Model settings
fixed_beta = 100;
ff = {'k_rho_alpha_ll_wmh'};
Np=[5];

options=optimset('display','off','DerivativeCheck','on');
warning('off','optim:fminunc:SwitchingMethod')

% -------------------------
% Get subject data
a = A(sj,:); 
r = R(sj,:); 
s = S(sj,:); 
b = B(sj,:); 
set_size = SZ(sj,:);

Z = [];  % No hierarchical prior for now (can be added later)

% -------------------------
% Initialize storage
LL = zeros(1,5);
P = cell(1,5);

% -------------------------
% Loop over K values
for k = 1:5
    ll = zeros(1,20);
    param = zeros(Np(f), 20);
    
    parfor ite = 1:20
        iter_start = tic; % Start of the iteration
        init = .1*randn(Np(f),1);
        disp(['Subject ' num2str(sj) ', Model ' ff{f} ', K = ' num2str(k) ', Iteration ' num2str(ite)]);
        [est,fval,ex] = fminsearch(@(x) feval(ff{f},x,a,r,s,b,set_size,k,Z,0,fixed_beta),init,options);
        ll(ite) = fval;
        param(:,ite) = est;
        iter_time = toc(iter_start); % End of the iteration
        disp(['Iteration time (s): ' num2str(iter_time)]);
    end
    
    [m,ind] = min(ll);
    LL(k) = m;
    P{k} = param(:,ind);
end

[~,K_idx] = min(LL);


% -------------------------
% Save subject result
outdir = fullfile('capacity', ff{f});
if ~exist(outdir,'dir'); mkdir(outdir); end

save(fullfile(outdir, sprintf('subj_%03d.mat', sj)), ...
    'K_idx','LL','P');

fprintf('Finished subject %d, model %s\n', sj, ff{f});

fprintf("END:   %s\n", datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf("Elapsed seconds: %.1f\n", toc(t0));

end
