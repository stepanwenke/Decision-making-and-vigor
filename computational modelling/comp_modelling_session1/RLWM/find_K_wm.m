clear;

load data_RLWM.mat

%% Settings
ff = {'ll_rlwm'}; % Select model 'll_rlwm' or 'll_wmh'
%%%

fixed_beta = 100; % Fixed beta at 100 when estimating WM capacity K

Np=[5]; % specify the number of parameters for each model (capacity K)

options=optimset('display','off','DerivativeCheck','on');
warning('off','optim:fminunc:SwitchingMethod')

for f=1:size(ff,2)

    % Preallocate or clear variables for this model
    K = [];
    LL = [];
    P = cell(size(A,1), 1);

    for sj=1:size(A,1)
        
        % print current subject to command window
        sprintf('%s', ['subj' num2str(sj)])
    
        a=A(sj,:); 
        r=R(sj,:);
        s=S(sj,:);
        b=B(sj,:);
        set_size=SetSize(sj,:);
        Z=[];
        
        % initialize
        ll=[]; param=[];
        
        for k = 1:5  % Loop over specific values of K - corresponding the set sizes 3, 4 and 6
            
            parfor ite=1:20 % Run 20 iterations of Maximum Likelihood Estimation (MLE)
                
                init=.1*randn(Np(f),1); % initialize random sample from normal prob distr
                
                % Find the minimum from ll_rlwm.m (negative log-likelihood of the RLWM model)
                [est,fval,ex]=fminsearch(@(x) feval(ff{f},x, a, r, s, b, set_size, k, Z,0,fixed_beta),init,options);
                
                % store NLL of current iteration
                ll(ite) = fval;
                
                % store estimated parameters of current iteration
                param(:,ite)=est;
                
            end % end parameter loop
            [m, ind] = min(ll); % get the value and index of the lowest NLL
            LL(sj,k) = m; % store it
            P{sj}(:,k) = param(:,ind); % store parameters for this subject
            
            %disp(k)
    
        end % end participant loop
    
        %k = [3, 4, 6];
        %LL = LL(:,k);
        
        %for sj = 1:53
        [m, ind] = min(LL(sj,:));
        K(sj) = ind;
        %end
    end
    
    save(['capacity_' ff{f} '.mat'], 'K', 'LL', 'P');

end
