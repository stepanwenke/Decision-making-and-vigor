% Find missing subject numbers
folder_path = 'day1/k_rho_alpha_ll_wmh/generated_from_original_model_rlwm/capacity/';
expected_total = 1000;

% Get all .mat files
files = dir(fullfile(folder_path, 'subj_*.mat'));

% Extract subject numbers from filenames
subject_numbers = zeros(length(files), 1);
for i = 1:length(files)
    filename = files(i).name;
    % Extract number between 'subj_' and '.mat'
    num_str = regexp(filename, 'subj_(\d+)\.mat', 'tokens');
    if ~isempty(num_str)
        subject_numbers(i) = str2double(num_str{1}{1});
    end
end

% Sort and find missing numbers
subject_numbers = sort(subject_numbers);
all_numbers = 1:expected_total;
missing_numbers = setdiff(all_numbers, subject_numbers);

% Display results
fprintf('Found %d subjects out of %d expected\n', length(subject_numbers), expected_total);
fprintf('Missing %d subjects:\n', length(missing_numbers));
disp(missing_numbers');

% Save missing numbers to file for SLURM
dlmwrite('missing_subjects.txt', missing_numbers, 'delimiter', '\n');
fprintf('\nMissing subject numbers saved to missing_subjects.txt\n');
