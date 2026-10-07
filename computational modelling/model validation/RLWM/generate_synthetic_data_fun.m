function generate_synthetic_data_fun(model_path, sim_model, samples, day)

    load([model_path 'parameters_RLWM_retest.mat']);
    
    % Add path to the trial matrix generation file
    addpath('../recoverability/rlwm');
    addpath('../recoverability/wmh');
    
    % Add path to the function that generates synthetic samples
    %addpath(['../recoverability/effort/day1/3iter/' sim_model]);
    
    mp = mu;
    stdev = nu;
    param = stdev.*randn(length(mp),samples)+mp*ones(1,samples);

    for s = 1:samples
        parameters = param(:,s);
        
        trial_matrix = shuffle_array(1,iters); % 1 = full matrix, num of iters
        stake_vector = trial_matrix(:,2)';
        effort_vector = trial_matrix(:,1)';
        n_trials = length(trial_matrix);
        [choices] = sim_physicalE (parameters, effort_vector,stake_vector,n_trials);
        
        data(s,1) = {struct('choices', choices', 'outcomes', stake_vector,'ELevel',effort_vector,'params', parameters)};
    end
    
    % Initialize arrays for storing extracted data
    A = [];
    R = [];
    ELevel = [];
    params = [];
    
    % Number of samples (participants)
    samples = length(data);
    
    % Loop over each synthetic dataset
    for s = 1:samples
        % Extract synthetic data
        synthetic_data = data{s};
        choices = synthetic_data.choices;
        outcomes = synthetic_data.outcomes;
        effort = synthetic_data.ELevel;
        param = synthetic_data.params;
        
        % Append to arrays
        A = [A; choices'];
        R = [R; outcomes];
        ELevel = [ELevel; effort];
        params = [params; param'];
    end
    
    % Last edit (cannot be 0, otherwise cannot be indexed)
    A(A == 0) = 2;
    
    % Create a folder of the current model if it doesn't exist
    output_dir = fullfile(pwd, ['day' num2str(day) filesep sim_model]);
    
    if ~exist(output_dir, 'dir')
        mkdir(output_dir)
    end
    
    % Save the synthetic data in a .mat file
    save([output_dir '/synthetic_data.mat'], 'A', 'R', 'ELevel', 'params');

end