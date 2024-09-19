function [boutSizeHist, successRate] = analyzeBouts(DATA)
% This function is for analyzing the bouts, providing their dirstribution
% and success rate for each bout size (Figure 3 of PiPaw2.0 Manuscript)
    n = size(DATA, 1);
    boutSizes = []; % Vector to store bout sizes
    successRates = []; % Vector to store success rates for each bout
    
    % Define event codes
    eventCodes.success = [3 4];
    eventCodes.fail = [53 54];
    eventCodes.ignored = [0 99];

    i = 1;
    while i <= n
        % Look for entrance
        if DATA{i,2} == 0
            successCount = 0; % Initialize success count
            trialCount = 0; % Initialize trial count
            i = i + 1; % Move to next event
            while DATA{i,2} ~= 99 && i <= n % Loop until exit or end of data
                if any(DATA{i,2} == eventCodes.success)
                    successCount = successCount + 1;
                    trialCount = trialCount + 1;
                elseif any(DATA{i,2} == eventCodes.fail)
                    trialCount = trialCount + 1;
                end
                i = i + 1; % Move to next event
            end
            if trialCount >= 2 % Check if bout had at least 2 trials
                boutSizes = [boutSizes trialCount]; % Save bout size
                successRates = [successRates successCount/trialCount]; % Save success rate
            end
        else
            i = i + 1; % Move to next event
        end
    end
    
    % Calculate distribution of bout sizes
    boutSizeHist = histcounts(boutSizes, 2:30);
    
    % Calculate average success rate for each bout size
    successRate = accumarray(boutSizes', successRates', [], @mean);
end
