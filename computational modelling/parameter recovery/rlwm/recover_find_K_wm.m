clear;

day = 2;

if day == 1
    load output/synthdata_RLWM_pilot2.mat;
else
    load output/synthdata_RLWM_pilot2day2.mat;
end

ff{1} = 'k_ll_rlwm'; % alpha and beta

Np=5; % specify the number of parameters for each model (capacity K)

options=optimset('display','off','DerivativeCheck','on');
warning('off','optim:fminunc:SwitchingMethod')

for sj=1:size(A,1)
    
    % print current subject to command window
    sprintf('%s', ['subj' num2str(sj)])

    % Get input data for current subject
    a=A(sj,:); 
    r=R(sj,:);
    s=S(sj,:);
    b=B(sj,:);
    set_size=SZ(sj,:);
    Z=[];
    
    % initialize
    ll=[]; param=[];
    for k=1:5 % for each capacity parameter (K)
        
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
        
    end % end participant loop
    
    [m, ind] = min(LL(sj,:));
    K(sj) = ind;
  
end

if day == 1
    save capacity_pilot2 K LL P;
else
    save capacity_retest K LL P;
end
