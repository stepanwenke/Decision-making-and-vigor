function recover_fit_WMH(current_ite)

    day = 1;
    parpool('local', 16)
    
    dt = '240228_EM_';
    fixed_beta = 10;
    
    if day == 1
        dtset = {'output/synthdata_WMH_pilot2'}; % put in the name of your datafile(s) (more than one is allowed). should contain A, R and S, and
        % (ideally) a subject list.
    else
        dtset = {'output/synthdata_WMH_pilot2day2'}; % put in the name of your datafile(s) (more than one is allowed). should contain A, R and S, and
    end
    
    for setind = 1:length(dtset)
    
        %load(dtset{setind})  %make all rewards scale to 1, 0 and -1
        load(dtset{setind}, 'A', 'B', 'params', 'R', 'S', 'SZ');
    
        if day == 1
            load capacity/capacity_k_rho_alpha_ll_wmh.mat K LL P % load capacity
        else
            load capacity_retest.mat % load capacity
        end
    
        clear LL P
    
        dtsetnm = strsplit(dtset{setind}, '_');
        dtsetnm = dtsetnm{3};
        if ~exist(dtsetnm, 'file')
            mkdir(dtsetnm)
        end
    
        dosave = 1;
        docomp = 0;
        docheck = 0;
        Nsample = 2000;
    
        ff{1} = 'k_rho_alpha_ll_wmh'; % alpha and beta - rlwm model
    
        Npar=5; % specify the number of parameters for each model
    
        options=optimset('display','off','DerivativeCheck','on');
        warning('off','optim:fminunc:SwitchingMethod')
        for whichinf=1:size(ff,2)
            for ite=current_ite:current_ite
    
                % initialize
                exx=[]; E=[]; V=[]; PL=[]; mu=[]; nu=[]; par=[]; lt=[]; et=[]; LLi=[]; iL=[]; bici=[];
    
                Np = Npar(whichinf);
    
                ld = [dt '-' ff{whichinf} '-ite' num2str(ite)];
    
                % initialize
                Nsj=size(A,1);
                %Nsj=1;
    
    
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
                        %for sj=1:Nsj
                        tic;
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
                            elapsedTime = toc;  % Get elapsed time in seconds
                            fprintf('Iteration %d took %.2f seconds.\n', ite, elapsedTime);
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
                        eval(['save ' dtsetnm filesep ld ' mu nu E V LL PL par et lt Z exx emit ld ff whichinf;']);
                    end
                    % check convergence ...........................................
                    if emit>1;if sum(abs(par(emit,2:end)-par(emit-1,2:end)))<1e-2;fprintf('\n *** converged *** \n');break;end;end
                end
            end
        end
    end



end