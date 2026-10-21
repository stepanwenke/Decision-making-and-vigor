clear;

%% Settings 
day = '1'; % Select session 1 or 2
model = 'll_rlwm'; % Choose model ll_rlwm or ll_wmh

%% to start parfor

dt = '240228_EM_';
fixed_beta = 10;
dtset = {['output_sim/synthdata_RLWM_' model '_session' day]}; % put in the name of your datafile(s) (more than one is allowed). should contain A, R and S, and
output_dir = ['output_fit/day' day filesep model];

for setind = 1:length(dtset)
    
    load(dtset{setind}) %make all rewards scale to 1, 0 and -1
    load(['capacity_RLWM_' model '_session' day '.mat']) % load capacity
    
    clear LL P

    dtsetnm = strsplit(dtset{setind}, '_');
    dtsetnm = dtsetnm{2};
    
    dosave = 1;
    docomp = 0;
    docheck = 0;
    Nsample = 2000;
    
    ff{1} = model; % alpha and beta - rlwm model
    
    Npar=5; % specify the number of parameters for each model
    
    options=optimset('display','off','DerivativeCheck','on');
    warning('off','optim:fminunc:SwitchingMethod')
    for whichinf=1:size(ff,2)
        for ite=1:10
            
            % initialize
            exx=[]; E=[]; V=[]; PL=[]; mu=[]; nu=[]; par=[]; lt=[]; et=[]; LLi=[]; iL=[]; bici=[];
            
            Np = Npar(whichinf);
            
            ld = [dt '-' ff{whichinf} '-ite' num2str(ite)];
            
            % initialize
            Nsj=size(A,1);
            Z.mu=zeros(Np,1);
            Z.nui=eye(Np);
            init=.1*randn(Np,1);
            
            E=zeros(Np,Nsj);
            V=zeros(Np,Nsj);
            PL=zeros(1,Nsj);
            exx=zeros(1,Nsj);
            LL=zeros(1,Nsj);
            
            init
            
            emit=0;
            while 1;emit=emit+1;sj=0;
                
                % E step......................................................
                
                parfor sj=1:Nsj % For each subject
                    fprintf('%2d\n',sj);
                    if isempty(A(sj,:))==0;
                        % get trials for current subject
                        a=A(sj,:);
                        r=R(sj,:);
                        s=S(sj,:);
                        b=B(sj,:);
                        set_size=SZ(sj,:);
                        
                        
                        init=.1*randn(Np,1);
                        if emit>1; init=E(:,sj); end
                        warning('off','optim:fminunc:SwitchingMethod')
                        [est,fval,ex]=fminsearch(@(x) feval(ff{whichinf},x, a, r, s, b, set_size, K(sj), Z,1,fixed_beta),init,options);
                        
                        mf=fval;mE=est;mx=ex;
                        for i=1:0
                            [est,fval,nex]=fminsearch(@(x) ...
                                feval(ff{whichinf},x, a, r, s, b, set_size, K(sj), Z,1,fixed_beta),init+.1*randn(Np,1),options);
                            if (fval < mf)
                                mf=fval;
                                mE=est;
                                mx=nex;
                            end
                        end
                        
                        fval=mf;
                        est=mE;
                        ex=mx;
                        
                        % 		    if ex<0 ; tmp=tmp+1; fprintf('didn''t converge %i times exit status %i\r',tmp,ex); end
                        
                        hess=NumHessian(@(x) feval(ff{whichinf},x, a, r, s, b, set_size, K(sj), Z,1,fixed_beta),est);
                        
                        exx(sj)=ex;
                        E(:,sj)=est;			% Subjets' parameter estimate
                        V(:,sj) = max(diag(inv(hess)),1e-5);	% inverse of Hessian = variance
                        PL(sj) = fval;
                        LL(sj)=feval(ff{whichinf},est, a, r, s, b, set_size, K(sj), Z,0,fixed_beta);
                        
                        fprintf('Emit=%i subject %i model %i iteration %i exit status=%i\r',emit,sj,whichinf,ite,exx(sj))
                    end
                end
                
                % M step using factorized posterior .................................
                mu = mean(E,2);
                %    nu = sqrt(sum(E.^2 + V,2)/Nsj - mu .^2); %change back to the line below lieke
                nu = sqrt(sum(E.^2,2)/Nsj + trimmean(V,10,2) - mu .^2); % fix to eliminate extreme values
                Z.mu = mu; Z.nui = inv(diag(nu));
                
                whichinf
                [mu nu]
                
                par(emit,:) = [sum(LL) sum(PL) mu' nu(:)'];						% save stuff
                et(emit,:,:) = E;
                lt(emit,:,:) = [LL; PL];
                
                if dosave;
                    eval(['save ' output_dir filesep ld ' mu nu E V LL PL par et lt Z exx emit ld ff whichinf;']);
                end
                % check convergence ...........................................
                if emit>1;if sum(abs(par(emit,2:end)-par(emit-1,2:end)))<1e-2;fprintf('\n *** converged *** \n');break;end;end
            end
        end
    end
end

% quit
pl=[];
for ite=1:10
    load ([output_dir filesep dt '-' ff{1} '-ite' num2str(ite)]);
    pl(ite)=sum(PL(1:end)); 
end

% Find the lowest pl
[min_value, min_index] = min(pl);

% Load parameters
load([output_dir filesep dt '-ll_rlwm-ite' num2str(min_index) '.mat']) % load best iteration (lowest posterior likelihood (pl))

% Transform parameters
transformed_E = 1./(1+exp(-E));
alpha = transformed_E(1,:);
lapse = transformed_E(2,:);
bias  = transformed_E(3,:);
decay = transformed_E(4,:);
rho   = transformed_E(5,:);

% save parameters
save([output_dir filesep 'parameters_RLWM.mat'], 'alpha', 'bias', 'decay', 'lapse', 'rho','mu','nu')

% Make figure
figure;
subplot(2,3,1)
hist(alpha)
title('alpha')
subplot(2,3,2)
hist(lapse)
title('lapse')
subplot(2,3,3)
hist(decay)
title('decay')
subplot(2,3,4)
hist(bias)
title('bias')
subplot(2,3,5)
hist(rho)
title('reliance rho')