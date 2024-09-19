

mousenames = ["6QP01","6QP02","6QP05","6QP06","6QP07","6QP08","6QP09","6QP10",...
"6QP11","6QP12","6QP13","6QP14","6QP15","6QP16","6QP17","6QP18","6QP19","6QP20",...
"6QP21","6QP22","6QP23","6QP24","6QP25","6QP26"];

for mouse = 1:24
    mouse
    animal = mousenames(mouse);
    load(animal+"_Blocks_processed.mat")

    isSuccess = ismember([blocks{:,3}], [3, 4]);
    n = 1;idx=[];dis=[];dis_z=[];
    while n<length(isSuccess)-5
        if all(isSuccess(n:n+4) == [0 0 0 0 0]) && (blocks{n+4,1}-blocks{n,1}<duration(0,2,30))
            idx = [idx,n];
            n = n+4;
        end
        n=n+1;
    end
    for i = 1:length(idx)
        n = idx(i);
        for m = 1:4
            dis(i,m) = dtw(blocks{n+m-1,2}(:,2),blocks{n+m,2}(:,2));
        end
        dis_z(i,:) = zscore(dis(i,:));
    end
    distances_fail(mouse,:) = nanmean(dis)';
    distances_fail_z(mouse,:) = nanmean(dis_z)';
    lng_fail(mouse) = length(idx);

    n = 1;idx=[];dis=[];dis_z=[];
    while n<length(isSuccess)-5
        if all(isSuccess(n:n+4) == [1 1 1 1 1]) && (blocks{n+4,1}-blocks{n,1}<duration(0,2,30))
            idx = [idx,n];
            n = n+4;
        end
        n=n+1;
    end
    for i = 1:length(idx)
        n = idx(i);
        for m = 1:4
            dis(i,m) = dtw(blocks{n+m-1,2}(:,2),blocks{n+m,2}(:,2));
        end
        dis_z(i,:) = zscore(dis(i,:));
    end
    distances_succ(mouse,:) = nanmean(dis)';
    distances_succ_z(mouse,:) = nanmean(dis_z)';
    lng_succ(mouse) = length(idx);
end
mm = zscore(distances_succ');

selectedColumns_WT = [1,2,3,4,6,10,13,15,16,17,21,22,23,24]; %WT
selectedData_WT = mm(selectedColumns_WT,:);
selectedColumns_Q = [5,7,8,9,11,12,14,18,19,20]; %Q175 11 and 12 removed
selectedData_Q = mm(selectedColumns_Q,:);
avgData_WT = nanmean(selectedData_WT);
semData_WT = nanstd(selectedData_WT) ./ sqrt(size(selectedData_WT, 1));
avgData_Q = nanmean(selectedData_Q);
semData_Q = nanstd(selectedData_Q) ./ sqrt(size(selectedData_Q, 1));
figure;
errorbar(1:4, avgData_WT, semData_WT);hold on
errorbar(1:4, avgData_Q, semData_Q);
xlabel('Day');
ylabel('Avg Pull Speed');
title('Pull Speed (Deg/s) ');




