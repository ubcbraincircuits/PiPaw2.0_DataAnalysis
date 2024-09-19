function bouts = findBouts(blocks)
% This function find bouts where a mouse performed at least 10 trials within at least 5
% minutes
    windowSize = minutes(5); % Window size of 5 minutes
    minTrials = 10; % Minimum number of trials for a bout
    timestamps = [blocks{:, 1}]; % Extract timestamps
    n = length(timestamps); % Total number of timestamps
    bouts = []; % Initialize bouts array

    i = 1; % Start index
    while i <= n
        windowEndTime = timestamps(i) + windowSize; % End time of the window
        count = 0; % Initialize trial count
        j = i; % Initialize end index

        % Count the number of trials in the window
        while j <= n && timestamps(j) <= windowEndTime
            count = count + 1;
            j = j + 1;
        end

        % Check if the count meets the minimum number of trials
        if count >= minTrials
            bouts = [bouts; i, j - 1]; % Add the bout to the list
            i = j; % Move the start index to the end of the current bout
        else
            i = i + 1; % Move to the next timestamp
        end
    end
end
