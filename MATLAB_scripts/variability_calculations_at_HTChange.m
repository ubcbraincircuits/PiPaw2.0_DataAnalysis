

mousenames = ["6QP01","6QP02","6QP05","6QP06","6QP07","6QP08","6QP09","6QP10",...
"6QP11","6QP12","6QP13","6QP14","6QP15","6QP16","6QP17","6QP18","6QP19","6QP20",...
"6QP21","6QP22","6QP23","6QP24","6QP25","6QP26"];

for m = 1:24
    m
    animal = mousenames(m);
    load(animal+"_Blocks_processed.mat")

    

    rqht = [blocks{:,5}];
    idx = find(diff(rqht) ~= 0) + 1;  % Add 1 because diff shifts indices by 1
    idx=idx(idx>10 & idx<length(rqht)-20);
    results = struct('DTWDistances', [], 'SuccessRates', [], 'HoldtimeSTDs', [], 'UniqueClusters', [], 'SuccessRates_mov', [], 'HoldtimeSTDs_mov', [], 'UniqueClusters_mov', [],'DTWDistances_mov',[]);
    for i = 1:size(idx, 2)
        startIndex = idx(i)-10;
        endIndex = idx(i)+19;
        dtwDistances = NaN(1, 30); % DTW distances.
        outcomes = zeros(1, 30); % Outcomes.
        holdtimes = zeros(1, 30); % Holdtimes.
        clusters = zeros(1, 30); % Clusters.
        
        % Process the first 10 trials in the bout.
        for n = startIndex:endIndex
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
        dtwDistances_mov = movmean(dtwDistances(2:end),[1 3]);
        % Calculate success rates for trials 1-5 and 11-15.
        successRates = [mean(ismember(outcomes(1:10), [3 4])), mean(ismember(outcomes(21:30), [3 4]))];
        successRates_mov = movmean(ismember(outcomes, [3 4]),[1 3]);
        % Calculate standard deviation of holdtimes for trials 1-5 and 11-15.
        holdtimeSTDs = [std(holdtimes(1:10)), std(holdtimes(21:30))];
        holdtimeSTDs_mov = movstd(holdtimes,[1 3]);
        % Calculate the number of unique clusters for trials 1-5 and 11-15.
        uniqueClusters = [length(unique(clusters(1:10))), length(unique(clusters(21:30)))];
        uniqueClusters_mov = countUniqueInWindow(clusters,5);
        % Store results.
        results.DTWDistances = [results.DTWDistances; dtwDistances];
        results.SuccessRates = [results.SuccessRates; successRates];
        results.HoldtimeSTDs = [results.HoldtimeSTDs; holdtimeSTDs];
        results.UniqueClusters = [results.UniqueClusters; uniqueClusters];
        results.SuccessRates_mov = [results.SuccessRates_mov; successRates_mov];
        results.HoldtimeSTDs_mov = [results.HoldtimeSTDs_mov; holdtimeSTDs_mov];
        results.UniqueClusters_mov = [results.UniqueClusters_mov; uniqueClusters_mov];
        results.DTWDistances_mov = [results.DTWDistances_mov; dtwDistances_mov];
    end 
    a=results.DTWDistances(:,2:end);
    for i = 1:size(a,1)
        b_f(i,:) = (a(i,:) - mean(a(i,1:9)) )./mean(a(i,1:9));
        if any(b_f(i,:)>100)
            b_f(i,:) = [];
        end
    end
    movv=results.DTWDistances_mov;
    for i = 1:size(movv,1)
        movv_f(i,:) = (movv(i,:) - mean(movv(i,1:4)) )./mean(movv(i,1:4));
        if any(movv_f(i,:)>100)
            movv_f(i,:) = [];
        end
    end

    b = zscore(a,[],2);
    vraw = a;
    b_sr(m,:) = nanmean(results.SuccessRates) ;
    b_hsd(m,:) = nanmean(results.HoldtimeSTDs) ;
    b_uq(m,:) = nanmean(results.UniqueClusters) ;
    b_sr_mov(m,:) = nanmean(results.SuccessRates_mov) ;
    b_hsd_mov(m,:) = nanmean(results.HoldtimeSTDs_mov) ;
    b_uq_mov(m,:) = nanmean(results.UniqueClusters_mov) ;
    % Now we do the same for control trials
    
    
    variability(:,m) = nanmean(b)';
    variability_f(:,m) = nanmean(b_f)';
    variability_raw(:,m) = nanmean(vraw)';
    variability_mov(:,m) = nanmean(movv_f)';
    b=[];b_f=[];movv_f=[];
end

mm = variability_mov';
mm = zscore(mm,[],1);

selectedColumns_WT = [1,2,3,4,6,10,13,15,16,17,21,22,23,24]; %WT
selectedData_WT = mm(:, selectedColumns_WT);
selectedColumns_Q = [5,7,8,9,11,12,14,18,19,20]; %Q175 11 and 12 removed
selectedData_Q = mm(:, selectedColumns_Q);
avgData_WT = nanmean(selectedData_WT, 2);
semData_WT = nanstd(selectedData_WT, 0, 2) ./ sqrt(size(selectedData_WT, 2));
avgData_Q = nanmean(selectedData_Q, 2);
semData_Q = nanstd(selectedData_Q, 0, 2) ./ sqrt(size(selectedData_Q, 2));
figure;
errorbar(1:29, avgData_WT, semData_WT);hold on
errorbar(1:29, avgData_Q, semData_Q);
xlabel('Day');
ylabel('Avg Pull Speed');
title('Pull Speed (Deg/s) ');




