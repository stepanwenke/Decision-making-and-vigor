function BIC = model_fitting_fun(sim_model,model_path,fit_model,files_generated,day)

dtset = {['day' num2str(day) filesep sim_model filesep 'synthetic_data']};
fitted_folder_path = ['day' num2str(day) filesep fit_model '/fitted_with_synthetic_' sim_model filesep];

if ~exist(fitted_folder_path, 'dir')
    mkdir(fitted_folder_path)
end

% Add path with the fitting function of the current model
fit_fun = [model_path '../'];
addpath(fit_fun);

% Which model to be fitted
ff{1} = [fit_model];

if files_generated == false
    for setind = 1:length(dtset)

        load(dtset{setind}, 'A','R','ELevel') %make all rewards scale to 1, 0 and -1

        dosave = 1;
        docomp = 0;
        docheck = 0;
        Nsample = 2000;

        Npar=[3]; % specify the number of parameters for each model

        options=optimset('display','off','DerivativeCheck','on');
        warning('off','optim:fminunc:SwitchingMethod')
        for whichinf=1:size(ff,2)
            for ite=1:10

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
                            Ef=ELevel(sj,:);

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

                            % Calculate BIC for each sample
                            BIC(sj) = Np * log(size(a,2)) - 2 * (-LL(sj));

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
                        eval(['save ' fitted_folder_path ld ' mu nu E V LL PL par et lt Z exx emit ld ff whichinf BIC;']);
                    end
                    % check convergence ...........................................
                    if emit>1;if sum(abs(par(emit,2:end)-par(emit-1,2:end)))<1e-2;fprintf('\n *** converged *** \n');break;end;end
                end

            end
        end
    end
end
% quit

pl=[];
for ite=1:10
    load ([fitted_folder_path ff{1} '-ite' num2str(ite)]);
    pl(ite)=sum(PL(1:end));
end

% Find the lowest pl
[min_value, min_index] = min(pl);

% Construct the filename based on the index
filename = [fitted_folder_path ff{1} '-ite' num2str(min_index) '.mat'];

% Load the file
load(filename);


% Extract beta and k parameters from 'E'
beta = E(1,:);
k = E(2,:);

if ff{1} == "quadratic_constrained"
    beta   = exp(E(1,:));             % sotmax inv temp
    k   = 1./(1+exp(-E(2,:)));     % discount rate
end

if ff{1} == "linear_constrained"
    beta   = exp(E(1,:));             % sotmax inv temp
end

g         = 1./(1+exp(-E(3,:)));      % lapse rate

% Plot histograms
% figure;
% hist(k,50);
% title('Histogram of k');
% xlabel('k');
% ylabel('Frequency');
% saveas(gcf, [fitted_folder_path 'k_retest.jpg']);  % Save histogram of k as JPEG file
% 
% figure;
% hist(beta,50);
% title('Histogram of beta');
% xlabel('beta');
% ylabel('Frequency');
% saveas(gcf, [fitted_folder_path 'beta_retest.jpg']);  % Save histogram of beta as JPEG file
% 
% figure;
% hist(g,50);
% title('Histogram of lapse');
% xlabel('lapse');
% ylabel('Frequency');
% saveas(gcf, [fitted_folder_path 'lapse_retest.jpg']);  % Save histogram of beta as JPEG file

% Save beta and k parameters to a .mat file
save([fitted_folder_path '/parameters_physicalE_retest.mat'], 'beta', 'k', 'g','mu','nu','BIC');

end