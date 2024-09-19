% Script for calculating the trial to trial variability 

% Get a list of all files in the current directory with the desired pattern.
files = dir('*_Blocks.mat');

% Extract the names of these files into a cell array.
fileNames = {files.name};

% Sort the filenames alphabetically.
sortedNames = sort(fileNames);

% Loop through each file
for i = 1:length(sortedNames)
    sortedNames{i}
    % Load the current file
    load(sortedNames{i});
    blocks(:, 9) = cellfun(@(x) max(x(x(:,1) > 0, 2)), blocks(:,2), 'UniformOutput', false);
    emptyCells = cellfun(@isempty, blocks(:,9));
    blocks(emptyCells, 9) = {0};
    
    variability_dist = movmean([blocks{:,8}],5); 
    variability_ht = movvar([blocks{:,4}],5);
    variability_theta = movvar([blocks{:,9}],5);
    
    % Find the indices of successful and unsuccessful trials
    successful_trials = find([blocks{:,3}] == 3 | [blocks{:,3}] == 4);
    unsuccessful_trials = find([blocks{:,3}] == 53 | [blocks{:,3}] == 54);
    
    % Initialize the matrices to store the results
    successful_var_matrix = zeros(length(successful_trials), 41);
    unsuccessful_var_matrix = zeros(length(unsuccessful_trials), 41);
    
    % For each successful trial, calculate the moving variance
    parfor i = 11:length(successful_trials)-30
        successful_var_matrix(i,:) = compute_moving_variance([blocks{:,9}], successful_trials(i), 10, 30, 5);
    end
    
    % For each unsuccessful trial, calculate the moving variance
    parfor i = 11:length(unsuccessful_trials)-30
        unsuccessful_var_matrix(i,:) = compute_moving_variance([blocks{:,9}], unsuccessful_trials(i), 10, 30, 5);
    end
    
    resultS{i} = successful_var_matrix;
    resultF{i} = unsuccessful_var_matrix;
end


resultF = cellfun(@(x) x(any(x,2),:), resultF, 'UniformOutput', false);
resultS = cellfun(@(x) x(any(x,2),:), resultS, 'UniformOutput', false);

for i =1:24    
    l = length(resultS{1,i});
    ind = round(l/10);
    SuccessV(i,:) = mean(resultS{1,i}(ind*3:ind*7,:));

    l = length(resultF{1,i});
    ind = round(l/10);
    FailV(i,:) = mean(resultF{1,i}(ind*3:ind*7,:));


end
wt_idx = [1:4,6,10,13,15:17,21:24]
q_idx = [5,7:9,11,12,14,18:20]

wtSVar = SuccessV(wt_idx,:);
wtFVar = FailV(wt_idx,:);

qSVar = SuccessV(q_idx,:);
qFVar = FailV(q_idx,:);


deltaVarWT = wtFVar - wtSVar;
deltaVarQ = qFVar - qSVar;

%[tau,y] = fit_exponential_decay(mean(deltaVarQ(:,12:end)))


a = detrend(deltaVarWT','linear');
deltaVarWT = a';
[tau,~] = fit_exponential_decay(deltaVarWT(:,12:end))


a = detrend(deltaVarQ','linear');
deltaVarQ = a';
[tau2,~] = fit_exponential_decay(deltaVarQ(:,12:end))

figure;plot_observation(mean(deltaVarWT(:,12:end)),1)
figure;plot_observation(mean(deltaVarQ(:,12:end)),1)

