clear;

%% to start parfor

% Which model do you want to fit - ll_rlwm is the original one.
ff = {'ll_wmh'};

dt = '240228_EM_';
fixed_beta = 10; % Beta parameter fixed at 10 when fitting

dtset = {'data_RLWM'}; % put in the name of your datafile(s) (more than one is allowed). should contain A, R and S, and
% (ideally) a subject list


for setind = 1:length(dtset)
    
    load(dtset{setind}) %make all rewards scale to 1, 0 and -1
           
    Npar=[5]; % specify the number of parameters for each model
    
    options=optimset('display','off','DerivativeCheck','on');
    warning('off','optim:fminunc:SwitchingMethod')
    for whichinf=1:size(ff,2)

        load(['capacity_' ff{whichinf} '.mat']) % load capacity
        clear LL P

        dtsetnm = ff{whichinf};
        if ~exist(dtsetnm, 'dir')
            mkdir(dtsetnm)
        end
        
        dosave = 1;
        docomp = 0;
        docheck = 0;
        Nsample = 2000;
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
                
                for sj=1:Nsj % For each subject
                    fprintf('%2d\n',sj);
                    if isempty(A(sj,:))==0;
                        % get trials for current subject
                        a=A(sj,:);
                        r=R(sj,:);
                        s=S(sj,:);
                        b=B(sj,:);
                        set_size=SetSize(sj,:);
                        
                        
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
                    eval(['save ' dtsetnm filesep ld ' mu nu E V LL PL par et lt Z exx emit ld ff whichinf;']);
                end
                % check convergence ...........................................
                if emit>1;if sum(abs(par(emit,2:end)-par(emit-1,2:end)))<1e-2;fprintf('\n *** converged *** \n');break;end;end
            end
        
        end
    end
end

%% Load the best iteration and save the parameters
%ff = {'ll_rlwm'};

for f = 1:size(ff,2)
    % quit
    pl=[];
    for ite=1:10
        load ([ff{f} filesep dt '-' ff{f} '-ite' num2str(ite)]);
        pl(ite)=sum(PL(1:end)); 
    end

    % Find the lowest pl
    [min_value, min_index] = min(pl);
    
    % Construct the filename based on the index
    filename = [ff{f} filesep dt '-' ff{f} '-ite' num2str(min_index)];
    
    % Load the file
    load(filename);
    
    
    % Load parameters
    param_names = {
        {'alpha', 'lapse', 'bias', 'decay', 'rho'}
    };

    % Transform parameters
    transformed_E = 1./(1+exp(-E));
    params = struct();

    for p = 1:length(param_names{f})

        this_param = param_names{f}{p};
        params.(this_param) = transformed_E(p,:);
    end
    % Plot histograms
    param_fields = fieldnames(params);
    plot_folder = [ff{f} filesep];

    for i = 1:numel(param_fields)
        pname = param_fields{i};
        params_values = params.(pname);
    
        % Skip if it's empty or not numeric
        if isempty(params_values) || ~isnumeric(params_values)
            continue
        end
    
        % Create histogram
        figure;
        histogram(params_values, 50);
        title(['Histogram of ' pname]);
        xlabel(pname);
        ylabel('Frequency');
    
        % Save figure
        saveas(gcf, fullfile(plot_folder, [pname '.jpg']));
        close(gcf);  % optional: close figure after saving
    end

    % save parameters
    save(fullfile(ff{f}, ['parameters_RLWM.mat']), ...
    'params', 'mu', 'nu', 'K');
end



