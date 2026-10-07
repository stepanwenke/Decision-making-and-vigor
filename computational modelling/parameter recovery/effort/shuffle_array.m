function [shuffled_array] = shuffle_array(full_matrix,trial_rep)
    % Define the trial matrix with combinations of effort and stake levels
    % 1 - effort, 2 - stake/reward
    % Possible combinations:
    if full_matrix == 1 % full matrix
    TRL_MATRIX = [
        1, 2; 1, 4; 1, 6; 1, 8; 1, 10;
        2, 2; 2, 4; 2, 6; 2, 8; 2, 10;
        3, 2; 3, 4; 3, 6; 3, 8; 3, 10;
        4, 2; 4, 4; 4, 6; 4, 8; 4, 10;
        5, 2; 5, 4; 5, 6; 5, 8; 5, 10;
    ];
    elseif full_matrix == 2 % w/o high reward
        TRL_MATRIX = [
            1, 2; 1, 4; 1, 6; 1, 8;
            2, 2; 2, 4; 2, 6; 2, 8;
            3, 2; 3, 4; 3, 6; 3, 8;
            4, 2; 4, 4; 4, 6; 4, 8;
            5, 2; 5, 4; 5, 6; 5, 8;
        ];
    elseif full_matrix == 3 % w/o low reward
        TRL_MATRIX = [
            1, 4; 1, 6; 1, 8; 1, 10;
            2, 4; 2, 6; 2, 8; 2, 10;
            3, 4; 3, 6; 3, 8; 3, 10;
            4, 4; 4, 6; 4, 8; 4, 10;
            5, 4; 5, 6; 5, 8; 5, 10;
        ];
    elseif full_matrix == 4 % w/o high effort
        TRL_MATRIX = [
            1, 2; 1, 4; 1, 6; 1, 8; 1, 10;
            2, 2; 2, 4; 2, 6; 2, 8; 2, 10;
            3, 2; 3, 4; 3, 6; 3, 8; 3, 10;
            4, 2; 4, 4; 4, 6; 4, 8; 4, 10;
        ];
    elseif full_matrix == 5 % w/o low effort
        TRL_MATRIX = [
            2, 2; 2, 4; 2, 6; 2, 8; 2, 10;
            3, 2; 3, 4; 3, 6; 3, 8; 3, 10;
            4, 2; 4, 4; 4, 6; 4, 8; 4, 10;
            5, 2; 5, 4; 5, 6; 5, 8; 5, 10;
        ];
    elseif full_matrix == 6 % w/o high effort/reward
        TRL_MATRIX = [
            1, 2; 1, 4; 1, 6; 1, 8;
            2, 2; 2, 4; 2, 6; 2, 8;
            3, 2; 3, 4; 3, 6; 3, 8;
            4, 2; 4, 4; 4, 6; 4, 8;
        ];
    elseif full_matrix == 7 % w/o low effort/reward
        TRL_MATRIX = [
            2, 4; 2, 6; 2, 8; 2, 10;
            3, 4; 3, 6; 3, 8; 3, 10;
            4, 4; 4, 6; 4, 8; 4, 10;
            5, 4; 5, 6; 5, 8; 5, 10;
        ];
    elseif full_matrix == 8 % w/o low/high reward
        TRL_MATRIX = [
            1, 4; 1, 6; 1, 8;
            2, 4; 2, 6; 2, 8;
            3, 4; 3, 6; 3, 8;
            4, 4; 4, 6; 4, 8;
            5, 4; 5, 6; 5, 8;
        ];
    elseif full_matrix == 9 % w/o high effort, low reward
        TRL_MATRIX = [
            1, 4; 1, 6; 1, 8; 1, 10;
            2, 4; 2, 6; 2, 8; 2, 10;
            3, 4; 3, 6; 3, 8; 3, 10;
            4, 4; 4, 6; 4, 8; 4, 10;
        ];
    elseif full_matrix == 10 % w/o low effort, high reward
        TRL_MATRIX = [
            2, 2; 2, 4; 2, 6; 2, 8;
            3, 2; 3, 4; 3, 6; 3, 8;
            4, 2; 4, 4; 4, 6; 4, 8;
            5, 2; 5, 4; 5, 6; 5, 8;
        ];
    elseif full_matrix == 11 % w/o low/high effort
        TRL_MATRIX = [
            2, 2; 2, 4; 2, 6; 2, 8; 2, 10;
            3, 2; 3, 4; 3, 6; 3, 8; 3, 10;
            4, 2; 4, 4; 4, 6; 4, 8; 4, 10;
        ];          
    else % full matrix
        TRL_MATRIX = [
            1, 2; 1, 4; 1, 6; 1, 8; 1, 10;
            2, 2; 2, 4; 2, 6; 2, 8; 2, 10;
            3, 2; 3, 4; 3, 6; 3, 8; 3, 10;
            4, 2; 4, 4; 4, 6; 4, 8; 4, 10;
            5, 2; 5, 4; 5, 6; 5, 8; 5, 10;
        ];
    end

    % Repeat each combination four times to get trial_rep * length(trial_matrix) trials
    repeated_matrix = repmat(TRL_MATRIX, trial_rep, 1);

    % Number of elements to shuffle
    n = size(repeated_matrix, 1);

    % Fisher-Yates shuffle algorithm
    for i = n:-1:2
        j = randi(i);  % Generate a random integer between 1 and i
        % Swap elements at indices i and j
        temp = repeated_matrix(i, :);
        repeated_matrix(i, :) = repeated_matrix(j, :);
        repeated_matrix(j, :) = temp;
    end

    % Return the shuffled array
    shuffled_array = repeated_matrix;

    % Display the shuffled array
%     disp('Shuffled array:');
%     disp(shuffled_array);
end

% Call the function to get the shuffled array
%[shuffled_array] = shuffle_array();
