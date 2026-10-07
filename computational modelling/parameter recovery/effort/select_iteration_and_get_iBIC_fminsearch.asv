clear all

dt = '240208_EM_';
day='1';
iters='3'; % only for the output name
models={'unconstrained_linear','constrained_quadratic', 'constrained_linear'};

fm{1} = 'unconstrained_linear'; % unconstrained_linear
fm{2} = 'constrained_quadratic'; % constrained_quadratic
fm{3} = 'constrained_linear'; % constrained_linear

% folder{1} = 'original effort';
% folder{2} = 'effort';

% Load data
target_path = ['../../comp_modelling_day' day '-prg_exclusions/Effort/physical/'];
addpath(target_path);
load([target_path 'data_physical_effort_retest.mat']);

Npar=[3 3 3];

docomp = 1;
Nsample = 2000;


for model=1:size(models,2)
    pl=[];
    for ite=1:10
        load ([target_path char(models(model)) filesep char(dt) '-' char(fm{model}) '-ite' num2str(ite) '.mat']);
        pl(ite)=PL(end);
    end
    
    [x y]=min(pl);
    SelectIte(model)=y;
    load ([target_path char(models{model}) filesep char(dt) '-' char(fm{model}) '-ite' num2str(y)]);
    Np = Npar(model);
    Nsj = length(A);
    ld = [char(dt) '-day' char(day) '-' char(models(model)) '-iter' char(iters) '-ite' num2str(y)];

    
    if docomp
        oo = ones(1,Nsample);
        muo = mu*oo; nuo = nu*oo;
        
        rand('seed',sum(100*clock));
        LLi=zeros(Nsample,1);
        ddl = zeros(Np,Nsj);
        
        for sj=1:size(A,2);
            fprintf('subject %i \r',sj)
            
            a=A(:,sj);
            r=R(:,sj);
            Ef=Elevel(:,sj);            
            
            est = diag(sqrt(nu))*randn(Np,Nsample)+mu*ones(1,Nsample);
            for k=1:Nsample;
                LLi(k)=feval(fm{model},est(:,k),a,r,Ef,Z,0);
                if ~mod(k,50);fprintf('model %i subject %i sample %i\r',model,sj,k);end
            end
            iL(sj) = log(sum(exp(-LLi))/Nsample);
        end
        
        
        % compute integrated BIC
        %for k=1:length(A); Nch(k)=length(A{k});end; Nch = Nch(:);
        Nch = size(A, 1) * ones(size(A,2), 1);  % same number of trials for each subject
        bici  = -2*sum(iL)   + 2*Np*log(sum(Nch)); % integrated BIC
        
        eval(['save ' ld '_meanerror bici iL mu nu E ld fm model']);
    end  
end