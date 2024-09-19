% Script for analyzing the trial variability metrics (Figure 6)

mousenames = ["6QP01","6QP02","6QP05","6QP06","6QP07","6QP08","6QP09","6QP10",...
"6QP11","6QP12","6QP13","6QP14","6QP15","6QP16","6QP17","6QP18","6QP19","6QP20",...
"6QP21","6QP22","6QP23","6QP24","6QP25","6QP26"];

for m = 1:24
    m
    animal = mousenames(m);
    load(animal+"_Blocks_processed.mat")

    % Assume 'blocks' is your cell array and 'bouts' is your matrix of bout indices.
    bouts = findBouts(blocks);
    % Results will be stored in this structure.
    results = struct('DTWDistances', [], 'SuccessRates', [], 'HoldtimeSTDs', [], 'UniqueClusters', []);
    
    % Loop through each bout.
    for i = 1:size(bouts, 1)
        startIndex = bouts(i, 1);
        endIndex = bouts(i, 2);
        % Determine the number of trials in the bout.
        numTrials = endIndex - startIndex + 1;
        % Check if the bout has at least 10 trials.
        if endIndex - startIndex + 1 >= 10
            % Initialize variables for this bout.
            dtwDistances = NaN(1, 10); % DTW distances.
            outcomes = zeros(1, 10); % Outcomes.
            holdtimes = zeros(1, 10); % Holdtimes.
            clusters = zeros(1, 10); % Clusters.
            
            % Process the first 10 trials in the bout.
            for n = startIndex:startIndex+9
                % Extract data for this trial.
                trialData = blocks{n, 2};
                outcomes(n - startIndex + 1) = blocks{n, 3};
                holdtimes(n - startIndex + 1) = blocks{n, 4};
                clusters(n - startIndex + 1) = blocks{n, 8};
                
                % Calculate DTW distance if not the first trial in the bout.
                if n > startIndex
                    prevTrialData = blocks{n-1, 2};
                    dtwDistances(n - startIndex + 1) = dtw(trialData(:, 2), prevTrialData(:, 2));
                end
            end
            
            % Calculate success rates for trials 1-5 and 11-15.
            successRates = [mean(ismember(outcomes(1:5), [3 4])), mean(ismember(outcomes(6:10), [3 4]))];
            
            % Calculate standard deviation of holdtimes for trials 1-5 and 11-15.
            holdtimeSTDs = [std(holdtimes(1:5)), std(holdtimes(6:10))];
            
            % Calculate the number of unique clusters for trials 1-5 and 11-15.
            uniqueClusters = [length(unique(clusters(1:5))), length(unique(clusters(6:10)))];
            
            % Store results.
            results.DTWDistances = [results.DTWDistances; dtwDistances];
            results.SuccessRates = [results.SuccessRates; successRates];
            results.HoldtimeSTDs = [results.HoldtimeSTDs; holdtimeSTDs];
            results.UniqueClusters = [results.UniqueClusters; uniqueClusters];
        end
    end
    
    a=results.DTWDistances(:,2:end);
    for i = 1:size(a,1)
        b(i,:) = (a(i,:) - mean(a(i,1:4)) )./mean(a(i,1:4));
        if any(b(i,:)>100)
            b(i,:) = [];
        end
    end
    b = zscore(a,[],2);
    vraw = a;
    b_sr(m,:) = nanmean(results.SuccessRates) ;
    b_hsd(m,:) = nanmean(results.HoldtimeSTDs) ;
    b_uq(m,:) = nanmean(results.UniqueClusters) ;
    % Now we do the same for control trials
    
    results = struct('DTWDistances', [], 'SuccessRates', [], 'HoldtimeSTDs', [], 'UniqueClusters', []);
    
    % Loop through each bout.
    for i = 1:size(bouts, 1)-1
        startIndex = bouts(i, 2);
        endIndex = bouts(i+1, 1);
        
        % Check if the bout has at least 15 trials.
        if endIndex - startIndex + 1 >= 10 && median(diff([blocks{startIndex:endIndex,1}]))>duration(0,0,29)
            % Initialize variables for this bout.
            dtwDistances = NaN(1, 10); % DTW distances.
            outcomes = zeros(1, 10); % Outcomes.
            holdtimes = zeros(1, 10); % Holdtimes.
            clusters = zeros(1, 10); % Clusters.
            
            % Process the first 15 trials in the bout.
            for n = startIndex:startIndex+9
                % Extract data for this trial.
                trialData = blocks{n, 2};
                outcomes(n - startIndex + 1) = blocks{n, 3};
                holdtimes(n - startIndex + 1) = blocks{n, 4};
                clusters(n - startIndex + 1) = blocks{n, 8};
                
                % Calculate DTW distance if not the first trial in the bout.
                if n > startIndex
                    prevTrialData = blocks{n-1, 2};
                    dtwDistances(n - startIndex + 1) = dtw(trialData(:, 2), prevTrialData(:, 2));
                end
            end
            
            % Calculate success rates for trials 1-5 and 11-15.
            successRates = [mean(ismember(outcomes(1:5), [3 4])), mean(ismember(outcomes(6:10), [3 4]))];
            
            % Calculate standard deviation of holdtimes for trials 1-5 and 11-15.
            holdtimeSTDs = [std(holdtimes(1:5)), std(holdtimes(6:10))];
            
            % Calculate the number of unique clusters for trials 1-5 and 11-15.
            uniqueClusters = [length(unique(clusters(1:5))), length(unique(clusters(6:10)))];
            
            % Store results.
            results.DTWDistances = [results.DTWDistances; dtwDistances];
            results.SuccessRates = [results.SuccessRates; successRates];
            results.HoldtimeSTDs = [results.HoldtimeSTDs; holdtimeSTDs];
            results.UniqueClusters = [results.UniqueClusters; uniqueClusters];
        end
    end
    a=results.DTWDistances(:,2:end);
    for i = 1:size(a,1)
        c(i,:) = (a(i,:) - mean(a(i,1:4)) )./mean(a(i,1:4));
        if any(c(i,:)>100)
            c(i,:) = [];
        end
    end
    c= zscore(a,[],2);
    cvraw = a;
    c_sr(m,:) = nanmean(results.SuccessRates) ;
    c_hsd(m,:) = nanmean(results.HoldtimeSTDs) ;
    c_uq(m,:) = nanmean(results.UniqueClusters) ;
    
    b_count(m) = size(b,1);
    c_count(m) = size(c,1);
    variability(:,m) = nanmean(b)';
    control(:,m) = nanmean(c)';
    variability_raw(:,m) = nanmean(vraw)';
    control_raw(:,m) = nanmean(cvraw)';
    b=[];c=[];
end


selectedColumns_WT = [1,2,3,4,6,10,13,15,16,17,21,22,23,24]; %WT
selectedData_WT = control(:, selectedColumns_WT);
selectedColumns_Q = [5,7,8,9,11,12,14,18,19,20]; %Q175 11 and 12 removed
selectedData_Q = control(:, selectedColumns_Q);
avgData_WT = nanmean(selectedData_WT, 2);
semData_WT = nanstd(selectedData_WT, 0, 2) ./ sqrt(size(selectedData_WT, 2));
avgData_Q = nanmean(selectedData_Q, 2);
semData_Q = nanstd(selectedData_Q, 0, 2) ./ sqrt(size(selectedData_Q, 2));
figure;
errorbar(1:9, avgData_WT, semData_WT);hold on
errorbar(1:9, avgData_Q, semData_Q);
xlabel('Day');
ylabel('Avg Pull Speed');
title('Pull Speed (Deg/s) ');




