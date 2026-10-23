clear;
%% to start parfor

dt = '240208_EM_';

dtset = {'data_physical_effort'}; % put in the name of your datafile(s) (more than one is allowed). should contain A, R and S, and
% (ideally) a subject list.


for setind = 1:length(dtset)
    
    load(dtset{setind}) %make all rewards scale to 1, 0 and -1

    dtsetnm = strsplit(dtset{setind}, '_');
    dtsetnm = dtsetnm{3};
  
    dosave = 1;
    docomp = 0;
    docheck = 0;
    Nsample = 2000;
    
    % Choose a desired model to be fitted: constrained_quadratic,
    % constrained_linear, and unconstrained linear
    ff{1} = 'constrained_linear'; 
    
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
                        Ef=Elevel(sj,:);
                        
                        init=.1*randn(Np,1);
                        if emit>1; init=E(:,sj); end
                        warning('off','optim:fminunc:SwitchingMethod')
                        [est,fval,ex]=fminsearch(@(x) feval(ff{whichinf},x, a, r, Ef, Z,1),init,options);
                        
                        mf=fval;mE=est;mx=ex;
                        for i=1:0
                            [est,fval,nex]=fminsearch(@(x) ...
                                feval(ff{whichinf},x, a, r, Ef, Z,1),init+.1*randn(Np,1),options);
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
                        
                        exx(sj)=ex;
                        E(:,sj)=est;			% Subjets' parameter estimate
                        V(:,sj) = max(diag(inv(hess)),1e-5);	% inverse of Hessian = variance
                        PL(sj) = fval;
                        LL(sj)=feval(ff{whichinf},est, a, r, Ef, Z,0);
                        
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
                    eval(['save ' ff{1} filesep ld ' mu nu E V LL PL par et lt Z exx emit ld ff whichinf;']);
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
    load ([ff{1} filesep dt '-' ff{1} '-ite' num2str(ite)]);
    pl(ite)=sum(PL(1:end));
end

% Find the lowest pl
[min_value, min_index] = min(pl);

% Construct the filename based on the index
filename = [ff{1} '/240208_EM_-' ff{1} '-ite' num2str(min_index) '.mat'];

% Load the file
load(filename);

% Extract beta and k parameters from 'E'
beta = E(1,:);
k = E(2,:);

if ff{1} == "constrained_quadratic"
    beta   = exp(E(1,:));             % sotmax inv temp
    k   = 1./(1+exp(-E(2,:)));     % discount rate
end

if ff{1} == "linear_constrained"
    beta   = exp(E(1,:));             % sotmax inv temp
end

g         = 1./(1+exp(-E(3,:)));      % lapse rate

% Create a folder with the name of the model if it doesn't exist
if ~exist(ff{1}, 'dir')
    mkdir(ff{1})
end


% Plot histograms
figure;
hist(k,50);
title('Histogram of k');
xlabel('k');
ylabel('Frequency');
saveas(gcf, [ff{1} '/k.jpg']);  % Save histogram of k as JPEG file

figure;
hist(beta,50);
title('Histogram of beta');
xlabel('beta');
ylabel('Frequency');
saveas(gcf, [ff{1} '/beta.jpg']);  % Save histogram of beta as JPEG file

figure;
hist(g,50);
title('Histogram of lapse');
xlabel('lapse');
ylabel('Frequency');
saveas(gcf, [ff{1} '/lapse.jpg']);  % Save histogram of beta as JPEG file



% Save beta and k parameters to a .mat file
save([ff{1} '/parameters_physicalE.mat'], 'beta', 'k', 'g','mu','nu');


