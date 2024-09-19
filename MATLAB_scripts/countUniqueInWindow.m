function uniqueCounts = countUniqueInWindow(data,windowSize)
    %windowSize = 10; % Size of the moving window
    n = length(data); % Length of the input array
    uniqueCounts = zeros(1, n - windowSize + 1); % Initialize the output array

    for i = 1:(n - windowSize + 1)
        windowData = data(i:(i + windowSize - 1)); % Extract the window
        uniqueCounts(i) = length(unique(windowData)); % Count unique values in the window
    end
end
