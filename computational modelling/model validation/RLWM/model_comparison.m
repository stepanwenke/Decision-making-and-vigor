clear all

%% Settings 
day = '1'; % Choose session 1 or 2
models = {'ll_wmh', 'll_rlwm'};
Npar = [5 5]; 

dt = '240228_EM_';
fm = models;
fixed_beta = 10;

% Load data
target_path = ['../../comp_modelling_session' day '/RLWM/'];
addpath(target_path);
load([target_path 'data_RLWM.mat']);

docomp = 1;
Nsample = 2;

% Pre-allocate storage for results
bici_values = zeros(1, length(models));
model_names = cell(1, length(models));

for model = 1:length(models)
    pl = [];
    for ite = 1:10
        load ([target_path char(models{model}) filesep char(dt) '-' char(fm{model}) '-ite' num2str(ite) '.mat']);
        pl(ite) = PL(end);
    end
    
    % Load the K param for each participant
    load([target_path 'capacity_' char(models(model))]);

    [x y] = min(pl);
    SelectIte(model) = y;
    
    % Load the best iteration
    load ([target_path char(models{model}) filesep char(dt) '-' char(fm{model}) '-ite' num2str(y)]);
    
    Np = Npar(model);
    Nsj = length(A);
    ld = [char(dt) '-day' char(day) '-' char(models{model}) '-ite' num2str(y)];

    if docomp
        oo = ones(1, Nsample);
        muo = mu * oo; nuo = nu * oo;
        
        rand('seed', sum(100*clock));
        LLi = zeros(Nsample, 1);
        ddl = zeros(Np, Nsj);
        
        for sj = 1:size(A, 1)
            fprintf('subject %i \r', sj)
            
            a=A(sj,:);
            r=R(sj,:);
            b=B(sj,:);
            s=S(sj,:);            
            set_size=SetSize(sj,:);
                   
            
            est = diag(sqrt(nu)) * randn(Np, Nsample) + mu * ones(1, Nsample);
            for k = 1:Nsample
                LLi(k) = feval(fm{model}, est(:,k),a,r,s,b,set_size,K(sj),Z,0,fixed_beta);
                if ~mod(k, 50)
                    fprintf('model %i subject %i sample %i\r', model, sj, k);
                end
            end
            iL(sj) = log(sum(exp(-LLi)) / Nsample);
        end
        
        % Compute integrated BIC
        Nch = size(A, 2) * ones(size(A, 1), 1);
        bici = -2 * sum(iL) + 2 * Np * log(sum(Nch));
        
        % Store for plotting
        bici_values(model) = bici;
        model_names{model} = models{model};
        
        save(['model_comp_output/' ld], 'bici', 'iL', 'mu', 'nu', 'E', 'ld', 'fm', 'model');
    end  
end

%% Plotting: Bar chart of Integrated BIC
figure('Color', 'white', 'Position', [100, 100, 800, 600]);
bar(bici_values, 'FaceColor', [0.4 0.2 0.8], 'EdgeColor', 'k', 'LineWidth', 1.5);
set(gca, 'XTickLabel', model_names, 'XTickLabelRotation', 45);

% Add value labels on top of bars
for i = 1:length(bici_values)
    text(i, bici_values(i) + max(bici_values)*0.02, ...
        sprintf('%.1f', bici_values(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 12, 'FontWeight', 'bold');
end

ylabel('Integrated BIC (Lower is Better)', 'FontSize', 14);
title(sprintf('Model Comparison (Session %s)', day), 'FontSize', 16);
grid on;
ylim([min(bici_values) - max(bici_values)*0.1, max(bici_values) + max(bici_values)*0.1]);

% Save the figure
figName = ['model_comp_output/bic_comparison_session' day '.png'];
saveas(gcf, figName);
fprintf('\nSaved BIC comparison plot to %s\n', figName);