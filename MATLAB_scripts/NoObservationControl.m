% This script is for calculating the no observation control (Figure 7F of
% the PiPaw Manuscript)

ControlGroup = cell(0,0);
for c = 1:9
    % Load data
    cageNumber = c; % Adjust as needed
    filename = ['cage' num2str(cageNumber) '.mat'];
    data = load(filename);
    varName = ['cage' num2str(cageNumber)];
    trials = data.(varName);
    clear data
    % Sort by timestamp
    [~, sortedIdx] = sort([trials{:,1}]);
    trials = trials(sortedIdx, :);
    % Parameters
    minTrials = 10;
    timeWindow = duration(0, 5, 0);
    % Identify all mice in the cage
    allMice = unique(trials(:,8));
    % Initialize results container
    results = containers.Map();
    % Identify success trials
    isSuccess = ismember([trials{:,3}], [3, 4]);
    % Loop over each mouse as the observing mouse
    for idx = 1:length(allMice)
        observingMouse = allMice{idx};
        timeoutResults = []; % [baseline, postTimeoutRate]
        % Loop through and identify sequences
        for i = (minTrials+1):(length(trials)-minTrials) % leave buffer of minTrials
            currMouse = trials{i,8};
            % Check for 10 trials of current observing mouse within 5 minutes
            if strcmp(currMouse, observingMouse) && trials{i,1} - trials{i-minTrials,1} <= timeWindow && all(strcmp(trials(i-minTrials:i,8), currMouse))
            % Check for 5-minute timeout
                if trials{i+1,1} - trials{i,1} >= timeWindow && trials{i+1,1} - trials{i,1} <= timeWindow*3 && all(strcmp(trials(i+1:i+minTrials,8), currMouse))
                    % Calculate observing mouse's baseline and post-timeout success rate
                    baselineRate = mean(isSuccess(i-minTrials:i-1));
                    postTimeoutRate = mean(isSuccess(i+1:i+minTrials));
                    timeoutResults = [timeoutResults; baselineRate, postTimeoutRate];
                end
            end
        end
        % Store timeoutResults in results
        results(observingMouse) = timeoutResults;
    end
    % Access the results for each observing mouse using results(observingMouse)
    %ControlGroup = table();
    % Loop through each pair
    for p = 1:size(allMice, 1)
        observer = allMice{p, 1};
        pairStr = observer;
        % Fetch the results for this pair
        resultMatrix = results(pairStr);
        % Separate data for ControlGroup and PotentialLearning
        controlData = resultMatrix;
        
        ControlGroup = [ControlGroup ; controlData];
        
    end
end