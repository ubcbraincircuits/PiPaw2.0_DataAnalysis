function [timeToSuccess, timeToFail, timestampsSuccess, timestampsFail] = timeToTrial(DATA)
    % initialize the result vectors
    timeToSuccess = [];
    timeToFail = [];
    timestampsSuccess = [];
    timestampsFail = [];
    
    % iterate over DATA
    for i = 1:size(DATA, 1)
        if DATA{i, 2} == 0 % entrance event
            enterTime = DATA{i, 1};
            successTrialCount = 0;
            failTrialCount = 0;
            for j = i+1:size(DATA, 1)
                switch DATA{j, 2}
                    case {3, 4} % successful trial
                        if successTrialCount == 0 % only consider the first trial after entrance
                            timeToSuccess = [timeToSuccess; seconds(DATA{j, 1} - enterTime)];
                            timestampsSuccess = [timestampsSuccess; DATA{j, 1}];
                        end
                        successTrialCount = successTrialCount + 1;
                    case {53, 54} % failed trial
                        if failTrialCount == 0 % only consider the first trial after entrance
                            timeToFail = [timeToFail; seconds(DATA{j, 1} - enterTime)];
                            timestampsFail = [timestampsFail; DATA{j, 1}];
                        end
                        failTrialCount = failTrialCount + 1;
                    case 99 % exit event
                        break; % exit the inner loop when the mouse exits
                end
            end
        end
    end
end
