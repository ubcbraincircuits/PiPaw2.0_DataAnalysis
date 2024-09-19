mousenames = ["6QP01","6QP02","6QP05","6QP06","6QP07","6QP08","6QP09","6QP10",...
"6QP11","6QP12","6QP13","6QP14","6QP15","6QP16","6QP17","6QP18","6QP19","6QP20",...
"6QP21","6QP22","6QP23","6QP24","6QP25","6QP26"];

for j = 1:24
    j
    m = Final_dist_matrix{1,j};
    dist = [];
    for i = 1:size(m,1)-1
        dist(i) = m(i,i+1);
    end
    distances{j} = dist;
end

positives= table();
distance = table();
variabilities = table();
srs_neg =table();
hts_neg =table();
pull_neg =table();
for j = 1:24
    mousename = mousenames(j)
    load(mousename+"_Blocks.mat")
    isSuccess = ismember([blocks{:,3}], [3, 4]);
    sr = movmean(isSuccess,10);
    dist=[];
    for i = 1:length(blocks)-1
        dist(i)=dtw(blocks{i,2}(:,2),blocks{i+1,2}(:,2));
    end
    var1 = movmean(dist,10);
    var2 = movstd([blocks{:,4}],10);
    pull = movmean(cellfun(@(x) abs(x(1,1)), blocks(:,2)),10);
    window_size = 15;
    consistent_windows = [];
    % Sliding window
    cnt = 0;
    while cnt<length(sr)-window_size-1
        cnt =cnt+1;
        window_data = sr(cnt:cnt+window_size-1);
        dur = diff([blocks{cnt:cnt+window_size,1}]);
        if blocks{cnt+window_size,1}-blocks{cnt,1}<duration(0,10,0)
            if mean(window_data(1:window_size/2))>0
                consistent_windows = [consistent_windows; cnt];
                cnt = cnt +window_size-1;
            end
        end
    end
    dist = [];
    variability = [];
    sr_n = [];
    ht_n = [];
    pull_n = [];
    cluster_n = [];
    for i = 1:length(consistent_windows)
        dist(i,:) = var1(consistent_windows(i):consistent_windows(i)+window_size)';
        variability(i,:) = var2(consistent_windows(i):consistent_windows(i)+window_size);
        sr_n(i,:) = sr(consistent_windows(i):consistent_windows(i)+window_size);
        ht_n(i,:) = [blocks{consistent_windows(i):consistent_windows(i)+window_size,4}];
        pull_n(i,:) = pull(consistent_windows(i):consistent_windows(i)+window_size);
        
    end
    f_dist = (dist - mean(dist(:,1:window_size/2),2)) ./ mean(dist(:,1:window_size/2),2);
    f_variability = (variability - mean(variability(:,1:window_size/2),2)) ./ mean(variability(:,1:window_size/2),2);
    f_sr_n = (sr_n - mean(sr_n(:,1:window_size/2),2)) ./ mean(sr_n(:,1:window_size/2),2);
    f_pull_n = (pull_n - mean(pull_n(:,1:window_size/2),2)) ./ mean(pull_n(:,1:window_size/2),2);
    f_ht_n = (ht_n - mean(ht_n(:,1:window_size/2),2)) ./ mean(ht_n(:,1:window_size/2),2);
    distance.(mousename) = mean(f_dist(:,1:21),1)';
    variabilities.(mousename) = mean(f_variability(:,1:21),1)';
    srs_neg.(mousename) = nanmean(f_sr_n(:,1:21),1)';
    pull_neg.(mousename) = nanmean(f_pull_n(:,1:21),1)';
    hts_neg.(mousename) = mean(f_ht_n(:,1:21),1)';
    data_size(j) = length(consistent_windows)
    %clearvars -except distances negatives positives zeros srs_neg srs_pos srs_z hts_neg hts_pos hts_z mousenames i
end
selectedColumns_WT = [1,2,3,4,6,10,13,15,16,17,21,22,23,24]; %WT
selectedData_WT = pull_neg{:, selectedColumns_WT};
selectedColumns_Q = [5,7,8,9,14,18,19,20]; %Q175 11 and 12 removed
selectedData_Q = pull_neg{:, selectedColumns_Q};
avgData_WT = mean(selectedData_WT, 2);
semData_WT = std(selectedData_WT, 0, 2) ./ sqrt(size(selectedData_WT, 2));
avgData_Q = mean(selectedData_Q, 2);
semData_Q = std(selectedData_Q, 0, 2) ./ sqrt(size(selectedData_Q, 2));
figure;
errorbar(1:21, avgData_WT, semData_WT);hold on
errorbar(1:21, avgData_Q, semData_Q);
xlabel('Trial Number');
ylabel('Fold Change in Pull Latency');
title('DTW Distance');