function countArray = countInMovingWindow(blocks)
    windowSize = minutes(5); % Define the window size as 5 minutes
    timestamps = [blocks{:, 1}]; % Extract the datetime objects
    n = length(timestamps); % Total number of timestamps
    countArray = zeros(n, 1); % Initialize the count array

    for i = 1:n
        windowEndTime = timestamps(i) + windowSize; % Define the end of the window
        count = 0; % Initialize the count for this window

        for j = i:n
            if timestamps(j) <= windowEndTime
                count = count + 1; % Increment the count if within the window
            else
                break; % Exit the loop if the timestamp is outside the window
            end
        end

        countArray(i) = count; % Assign the count to the array
    end
end
