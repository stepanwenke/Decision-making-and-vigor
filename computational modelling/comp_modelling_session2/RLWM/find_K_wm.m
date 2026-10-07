clear;

load data_RLWM_retest.mat

ff{1} = 'k_ll_rlwm'; % alpha and beta
Np=5; % specify the number of parameters for each model (capacity K)

options=optimset('display','off','DerivativeCheck','on');
warning('off','optim:fminunc:SwitchingMethod')

for sj=1:size(A,1)
    
    % print current subject to command window
    sprintf('%s', ['subj' num2str(sj)])

    % Get input data for current subject% Create a participant x parameter matrix
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
            
            init=.1*randn(Np,1); % initialize random sample from normal prob distr
            
            % Find the minimum from ll_rlwm.m (negative log-likelihood of the RLWM model)
            [est,fval,ex]=fminsearch(@(x) feval(ff{1},x, a, r, s, b, set_size, k, Z,0),init,options);
            
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

save capacity_retest K LL P


