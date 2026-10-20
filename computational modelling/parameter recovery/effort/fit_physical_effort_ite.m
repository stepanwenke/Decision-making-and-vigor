clear;
%% to start parfor

% Settings
day='1';
model={'unconstrained_linear'}; % constrained_linear, unconstrained_linear and constrained_quadratic
%%%%

dt = 'recover_real';
target_path = ['day' day filesep model{1} filesep];
dtset = {[target_path 'output_sim/synthdata_physE']}; % put in the name of your datafile(s) (more than one is allowed). should contain A, R and S, and
model_path = ['../../comp_modelling_session' day '/Effort/physical/'];

addpath(target_path);
addpath(model_path);
% (ideally) a subject list.


for setind = 1:length(dtset)
    
    load(dtset{setind}) %make all rewards scale to 1, 0 and -1

    dtsetnm = strsplit(dtset{setind}, '_');
    dtsetnm = dtsetnm{1};
    
    dosave = 1;
    docomp = 0;
    docheck = 0;
    Nsample = 2000;
    
    ff = model;
    
    Npar=[3]; % specify the number of parameters for each model
    
    options=optimset('display','off','DerivativeCheck','on');
    warning('off','optim:fminunc:SwitchingMethod')
    for whichinf=1:size(ff,2)
        for ite=1:10
            
            exx=[]; E=[]; V=[]; PL=[]; mu=[]; nu=[]; par=[]; lt=[]; et=[]; LLi=[]; iL=[]; bici=[];
            
            Np = Npar(whichinf);
            
            ld = [dt '-' ff{whichinf} '-ite' num2str(ite)];
            
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
                
                parfor sj=1:Nsj
                    fprintf('%2d\n',sj);
                    if isempty(A(sj,:))==0;
                        a=A(sj,:);
                        r=R(sj,:);
                        Ef=ELevel(sj,:);
                        
                        init=.1*randn(Np,1);
                        if emit>1; init=E(:,sj); end
                        warning('off','optim:fminunc:SwitchingMethod')
                        [est,fval,ex]=fminsearch(@(x) feval(ff{whichinf},x, a, r, Ef, Z,1),init,options);
                        %[est,fval,ex]=fminsearch(@(x) ff{whichinf}(x, a, r, Ef, Z,1),init,options);

                        mf=fval;mE=est;mx=ex;
                        for i=1:0
                                [est,fval,nex]=fminsearch(@(x) ff{whichinf}(x, a, r, Ef, Z,1),init+.1*randn(Np,1),options);
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
                        
                        
                        hess=NumHessian(@(x) feval(ff{whichinf},x, a, r, Ef, Z,1),est);
                        %hess=NumHessian(@(x) ff{whichinf}(x, a, r, Ef, Z,1),est);
                        
                        exx(sj)=ex;
                        E(:,sj)=est;			% Subjets' parameter estimate
                        V(:,sj) = max(diag(inv(hess)),1e-5);	% inverse of Hessian = variance
                        PL(sj) = fval;
                        LL(sj)=feval(ff{whichinf},est, a, r, Ef, Z,0);
                        %LL(sj)=ff{whichinf}(est, a, r, Ef, Z,0);
                        
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
                    eval(['save ' target_path filesep 'output_fit' filesep ld ' mu nu E V LL PL par et lt Z exx emit ld ff whichinf;']);
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
    load ([target_path filesep 'output_fit' filesep 'recover_real-' model{1} '-ite' num2str(ite)]);
    pl(ite)=sum(PL(1:end));
end

% Find the lowest pl
[min_value, min_index] = min(pl);

% Construct the filename based on the index
filename = [target_path filesep 'output_fit' filesep 'recover_real-' model{1} '-ite' num2str(min_index) '.mat'];

% Load the file
load(filename);

% Extract beta and k parameters from 'E'
beta = E(1,:);
k = E(2,:);

if model == "constrained_linear" || model == "constrained_quadratic"
    beta 	  = exp(E(1,:));             % sotmax inv temp
    disp('beta constrained');
end

if model == "constrained_quadratic"
    k    	  = 1./(1+exp(-E(2,:)));     % discount rate
    disp('k constrained')
end

g         = 1./(1+exp(-E(3,:)));      % lapse rate

% Plot histograms
figure;
hist(k,50);
title('Histogram of k');
xlabel('k');
ylabel('Frequency');
saveas(gcf, [target_path 'output_fit/k.jpg']);  % Save histogram of k as JPEG file

figure;
hist(beta,50);
title('Histogram of beta');
xlabel('beta');
ylabel('Frequency');
saveas(gcf, [target_path 'output_fit/beta.jpg']);  % Save histogram of beta as JPEG file

figure;
hist(g,50);
title('Histogram of lapse');
xlabel('lapse');
ylabel('Frequency');
saveas(gcf, [target_path 'output_fit/lapse.jpg']);  % Save histogram of beta as JPEG file


% Save beta and k parameters to a .mat file
save([target_path filesep  'output_fit/parameters_physicalE.mat'], 'beta', 'k', 'g','mu','nu');


