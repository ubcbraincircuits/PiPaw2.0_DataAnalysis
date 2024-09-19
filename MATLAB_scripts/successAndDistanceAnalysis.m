
num_trials = size(blocks, 1);
similarity_scores = zeros(num_trials, 1);

for i = 2:num_trials
    similarity_scores(i) = dtw(blocks{i-1, 2}(:, 2), blocks{i, 2}(:, 2));
end

blocks(:,8)= num2cell(similarity_scores);


% Determine the earliest and latest time
t_min = min([blocks{:,1}]);
t_max = max([blocks{:,1}]);

% Total number of seconds between earliest and latest trial
total_seconds = round(seconds(t_max - t_min));

% Initialize matrices to zeros
success_matrix = zeros(1, total_seconds);
distance_matrix = zeros(1, total_seconds);

% Get start and end seconds for each trial
start_seconds = round(cellfun(@(x) max(1, seconds(x - t_min)), blocks(:,1)));
end_seconds = ceil(start_seconds + cell2mat(blocks(:,4)));

% Find successful trials (3 or 4 in third column)
successful_trials = cell2mat(blocks(:,3)) == 3 | cell2mat(blocks(:,3)) == 4;

% Compute indices for successful trials
idx = arrayfun(@(s, e) s:e, start_seconds(successful_trials), end_seconds(successful_trials), 'UniformOutput', false);

% Update success_matrix using logical indexing
success_matrix([idx{:}]) = 1;

% Compute indices for all trials
idx_all = arrayfun(@(s, e) s:e, start_seconds, end_seconds, 'UniformOutput', false);
% Compute the repeated 8th column values for each trial
repeated_values = arrayfun(@(val, len) repmat(val, 1, len), cell2mat(blocks(:,8)), end_seconds - start_seconds + 1, 'UniformOutput', false);

% Update distance_matrix using logical indexing
distance_matrix([idx_all{:}]) = [repeated_values{:}];
% Perform Min-Max scaling
scaled_distance_matrix = (distance_matrix - min(distance_matrix)) / (max(distance_matrix) - min(distance_matrix));






% Define the time constant
tau = 30;  % Change this to the desired value

% Create the exponential function
t = 0:60;
exp_func = exp(-t/tau);
% Create the reversed exponential function
exp_func_rev = fliplr(exp_func);

% Convolve the result_matrix with the reversed exponential function
result_matrix_exp = conv(success_matrix, exp_func_rev, 'same');
distance_matrix_exp = conv(scaled_distance_matrix, exp_func_rev, 'same');

[r,lags] = xcorr (result_matrix_exp,scaled_distance_matrix,600);
plot(lags,r)
