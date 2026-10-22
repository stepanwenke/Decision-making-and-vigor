function BIC = model_fitting_fun_job(sim_model_idx,fit_model_idx,files_generated,day,input_ite)

parpool('local', 16);

models = {'k_rho_alpha_ll_wmh', 'original_model_rlwm'};
fit_model = models{fit_model_idx};
sim_model = models{sim_model_idx};

model_path=['../../comp_modelling_session1/RLWM/model comparison/' fit_model filesep];

dtset = {['day' num2str(day) filesep sim_model filesep 'synthetic_data']};
fitted_folder_path = ['day' num2str(day) filesep fit_model '/fitted_on_' sim_model filesep];
capacity_path = ['day' num2str(day) filesep sim_model filesep 'generated_from_' sim_model filesep 'capacity_k'];

if ~exist(fitted_folder_path, 'dir')
    mkdir(fitted_folder_path)
end

% Add path with the fitting function of the current model
fit_fun = [model_path '../'];
addpath(fit_fun);

% Which model to be fitted
ff{1} = [fit_model];
fixed_beta = 10;

    if files_generated == false
        for setind = 1:length(dtset)
    
            load(dtset{setind}, 'A','R','S','B','SZ'); % Load the synthetic data
            load(capacity_path, 'LL', 'P', 'K'); % Load the corresponding capacity
    
            dosave = 1;
            docomp = 0;
            docheck = 0;
            Nsample = 2000;
    
            Npar=[5]; % specify the number of parameters for each model
    
            options=optimset('display','off','DerivativeCheck','on');
            warning('off','optim:fminunc:SwitchingMethod')
            for whichinf=1:size(ff,2)
                for ite=input_ite:input_ite
    
                    exx=[]; E=[]; V=[]; PL=[]; mu=[]; nu=[]; par=[]; lt=[]; et=[]; LLi=[]; iL=[]; bici=[];
    
                    Np = Npar(whichinf);
    
                    ld = [ff{whichinf} '-ite' num2str(ite)];
    
                    Nsj=size(A,1);
                    Z.mu=zeros(Np,1);
                    Z.nui=eye(Np);
                    init=.1*randn(Np,1);
    
                    E=zeros(Np,Nsj);
                    V=zeros(Np,Nsj);
                    PL=zeros(1,Nsj);
                    exx=zeros(1,Nsj);
                    LL=zeros(1,Nsj);
                    BIC=zeros(1,Nsj);  
    
                    init
    
                    emit=0;
                    while 1;emit=emit+1;sj=0;
    
                        % E step......................................................
    
                        parfor sj=1:Nsj
                            fprintf('%2d\n',sj);
                            if isempty(A(sj,:))==0;
                                a=A(sj,:);
                                r=R(sj,:);
                                s=S(sj,:);
                                b=B(sj,:);
                                set_size=SZ(sj,:);
                                
    
                                init=.1*randn(Np,1);
                                if emit>1; init=E(:,sj); end
                                warning('off','optim:fminunc:SwitchingMethod')
                                [est,fval,ex]=fminsearch(@(x) feval(ff{whichinf},x, a, r, s, b, set_size, K(sj),Z,1, fixed_beta),init,options);
    
                                mf=fval;mE=est;mx=ex;
                                for i=1:0
                                    [est,fval,nex]=fminsearch(@(x) ...
                                        feval(ff{whichinf},x, a, r, s, b, set_size,K(sj), Z,1, fixed_beta),init+.1*randn(Np,1),options);
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
    
                                hess=NumHessian(@(x) feval(ff{whichinf},x, a, r, s, b, set_size,K(sj), Z,1, fixed_beta),est);
    
                                exx(sj)=ex;
                                E(:,sj)=est;			% Subjets' parameter estimate
                                V(:,sj) = max(diag(inv(hess)),1e-5);	% inverse of Hessian = variance
                                PL(sj) = fval;
                                LL(sj)=feval(ff{whichinf},est, a, r, s, b, set_size, K(sj),Z,0, fixed_beta);
    
                                % Calculate BIC for each sample
                                BIC(sj) = Np * log(size(a,2)) - 2 * (-PL(sj));
    
                                fprintf('Emit=%i subject %i model %i iteration %i exit status=%i\r',emit,sj,whichinf,ite,exx(sj))
                            end
                        end
    
                        % M step using factorized posterior .................................
                        mu = mean(E,2);
                        nu = sqrt(sum(E.^2,2)/Nsj + trimmean(V,10,2) - mu .^2); % fix to eliminate extreme values
                        Z.mu = mu; Z.nui = inv(diag(nu));
    
                        whichinf
                        [mu nu]
    
                        par(emit,:) = [sum(LL) sum(PL) mu' nu(:)'];						% save stuff
                        et(emit,:,:) = E;
                        lt(emit,:,:) = [LL; PL];
    
                        if dosave;
                            eval(['save ' fitted_folder_path ld ' mu nu E V LL PL par et lt Z exx emit ld ff whichinf BIC K;']);
                        end
                        % check convergence ...........................................
                        if emit>1;if sum(abs(par(emit,2:end)-par(emit-1,2:end)))<1e-2;fprintf('\n *** converged *** \n');break;end;end
                    end
    
                end
            end
        end
    end
% quit


end