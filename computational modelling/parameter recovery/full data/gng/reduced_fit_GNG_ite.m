%%%%%%%%%%%%%%%%%
%%% Written by Quentin J. M. Huys, UCL, 2011, modified by Lieke de
%%% Boer
%%% References:
%%% Guitart-Masip M, Quentin JM, Fuentemilla LL, Dayan P, Duzel E, Dolan RJ (2012)
%%% Go and no-go learning in reward and punishment: Interaction between affect and effect NeuroImage doi:10.1016/j.neuroimage.2012.04.024
%%% de Boer, L., J Axelsson, R Chowdhury, K Riklund, RJ Dolan, L Nyberg, L
%%% B�ckman, M Guitart-Masip (2019).Dorsal striatal dopamine D1 receptor availability predicts an
%%% instrumental bias in action learning. PNAS doi: 10.1073/pnas.1816704116

clear all;

%% to start parfor
% c=parcluster;
% c.NumWorkers=16 ; % 22 is the maxnumber of workers you're allowed
% parpool(16) ; % same thing

dt = '240207_EM_';
day = 1;

if (day == 1)
    dtset = {'output/synthdata_GNG_pilot2'}; % put in the name of your datafile(s) (more than one is allowed). should contain A, R and S, and
else
    dtset = {'output/synthdata_GNG_pilot2day2'};
end
% (ideally) a subject list.


for setind = 1:length(dtset)
    
    load(dtset{setind}) %make all rewards scale to 1, 0 and -1
    %     for i = 1:length(R)
    %         r=R{i};
    %         r=r./abs(r);
    %         r(isnan(r))=0;
    %         R{i}=r;
    %     end
    dtsetnm = strsplit(dtset{setind}, '_');
    dtsetnm = dtsetnm{3};
    if ~exist(dtsetnm, 'file')
        mkdir(dtsetnm)
    end
    
    dosave = 1;
    docomp = 0;
    docheck = 0;
    Nsample = 2000;
    
    ff{1} = 'll_zorowitz'; % alpha and beta
    
    % rx
    Npar=[4]; % specify the number of parameters for each model
    
    options=optimset('display','off','DerivativeCheck','on');
    warning('off','optim:fminunc:SwitchingMethod')
    for whichinf=1:size(ff,2)
        for ite=1:10
            % initialize
            exx=[]; E=[]; V=[]; PL=[]; mu=[]; nu=[]; par=[]; lt=[]; et=[]; LLi=[]; iL=[]; bici=[];
            
            Np = Npar(whichinf); % Number of parameters
            
            % Name of the output file from current iteration
            ld = [dt '-' ff{whichinf} '-ite' num2str(ite)]; 
            
            Nsj=size(A,1); % nr of participants
            Z.mu=zeros(Np,1); % Parameters initialized (0 on first iteration)
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
                
                parfor sj=1:Nsj % for each subject
                    fprintf('%2d\n',sj);
                    if isempty(A(sj,:))==0;
                        a=A(sj,:);
                        r=R(sj,:);
                        s=S(sj,:);
                        val=Val(sj,:);
                        
                        
                        init=.1*randn(Np,1);
                        if emit>1; init=E(:,sj); end
                        warning('off','optim:fminunc:SwitchingMethod')
                        [est,fval,ex]=fminsearch(@(x) feval(ff{whichinf},x, a, r, s, val, Z,1),init,options);
                        
                        mf=fval;mE=est;mx=ex;
                        for i=1:0
                            [est,fval,nex]=fminsearch(@(x) ...
                                feval(ff{whichinf},x, a, r, s, val, Z,1),init+.1*randn(Np,1),options);
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
                        
                        hess=NumHessian(@(x) feval(ff{whichinf},x, a, r, s, val, Z,1),est);
                        
                        exx(sj)=ex;
                        E(:,sj)=est;			% Subjets' parameter estimate
                        V(:,sj) = max(diag(inv(hess)),1e-5);	% inverse of Hessian = variance
                        PL(sj) = fval;
                        LL(sj)=feval(ff{whichinf},est, a, r, s, val, Z,0);
                        
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
                    eval(['save ' dtsetnm filesep ld ' mu nu E V LL PL par et lt Z exx emit ld ff whichinf;']);
                end
                % check convergence ...........................................
                if emit>1;if sum(abs(par(emit,2:end)-par(emit-1,2:end)))<1e-2;fprintf('\n *** converged *** \n');break;end;end
            end
            
        end
    end
end
% quit
pl=[];
for ite=1:10 % For each iteration
    load ([dtsetnm filesep dt '-' ff{1} '-ite' num2str(ite)]); % load log-likelihood 
    pl(ite)=sum(PL(1:end)); % add it to variable pl 
end

% Load parameters
[val, ix] = min(pl);

% if loading later - use this
if (day == 1)
    dtset = {'output/synthdata_GNG_pilot2'};
else
    dtset = {'output/synthdata_GNG_pilot2day2'};
end

dtsetnm = strsplit(dtset{1}, '_');
dtsetnm = dtsetnm{3};

load([dtsetnm filesep '240207_EM_-ll_zorowitz-ite2.mat']) % load best iteration (lowest posterior likelihood (pl) => the min)
% Transform parameters
betas = exp(E(1:2,:)); % beta params (row 1:reward, row 2:punishment)
alphas = 1./(1+exp(-E(3:4,:))); % alpha params (row 1:reward, row 2:punishment)
eps = exp(E(5:6,:)); % epsilon params (approach/avoid bias; row 1:reward, row 2:punishment)
lapse = 1./(1+exp(-E(7,:))); % lapse rate
% save parameters

if (day == 1)
    save([dtsetnm filesep 'parameters_GNG_pilot2_synthetic.mat'], 'betas', 'alphas', 'eps', 'lapse')
else
    save([dtsetnm filesep 'parameters_GNG_pilot2_synthetic_day2.mat'], 'betas', 'alphas', 'eps', 'lapse')
end


