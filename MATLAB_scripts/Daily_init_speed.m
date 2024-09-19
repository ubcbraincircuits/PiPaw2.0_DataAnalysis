% This script is for calculating the daily average of initial pull speed.

mousenames = ["6QP01","6QP02","6QP05","6QP06","6QP07","6QP08","6QP09","6QP10",...
"6QP11","6QP12","6QP13","6QP14","6QP15","6QP16","6QP17","6QP18","6QP19","6QP20",...
"6QP21","6QP22","6QP23","6QP24","6QP25","6QP26"];
daily_speed = cell(1,24);
daily_speed_success= cell(1,24);
daily_speed_fail= cell(1,24);
for j = 1:24
    j
    animal = mousenames(j);
    load(animal+"_Blocks.mat")
    blocks(:, 2) = cellfun(@(x) x(x(:, 1) >= 0, :), blocks(:, 2), 'UniformOutput', false);
    dayChangeIndices = [1; find(diff(day([blocks{:,1}]')) ~= 0)+1];
    speed = cellfun(@(x) mean(diff(x(1:5,2))/0.0125), blocks(:,2),'ErrorHandler', @(err, varargin) NaN); %degrees/sec
    if dayChangeIndices(end)>length(speed)
        dayChangeIndices = dayChangeIndices(1:end-1);
    end
    successful_mask = [blocks{:,3}] == 3 | [blocks{:,3}] == 4;
    failed_mask = [blocks{:,3}] == 53 | [blocks{:,3}] == 54;

    daily_speed{j} = arrayfun(@(x,y) nanmean(speed(x:y-1)), dayChangeIndices(1:end-1), dayChangeIndices(2:end));
    speed_f = speed; speed_f(successful_mask)=NaN; %failed = not successful
    speed_s = speed; speed_s(failed_mask)=NaN; %successful = not failed
    daily_speed_success{j} = arrayfun(@(x,y) nanmean(speed_s(x:y-1)), dayChangeIndices(1:end-1), dayChangeIndices(2:end));
    daily_speed_fail{j} =  arrayfun(@(x,y) nanmean(speed_f(x:y-1)), dayChangeIndices(1:end-1), dayChangeIndices(2:end));
end




spd_f = zeros(130,24);
for i = 1:24
    for j = 1:length(daily_speed_fail{i})
        spd_f(j,i) = daily_speed_fail{i}(j);
    end
end

selectedColumns_WT = [1,2,3,4,6,10,13,15,16,17,21,22,23,24]; %WT
selectedData_WT = spd(1:58, selectedColumns_WT);
selectedColumns_Q = [5,7,8,9,11,12,14,18,19,20]; %Q175 11 and 12 removed
selectedData_Q = spd(1:58, selectedColumns_Q);
avgData_WT = nanmean(selectedData_WT, 2);
semData_WT = nanstd(selectedData_WT, 0, 2) ./ sqrt(size(selectedData_WT, 2));
avgData_Q = nanmean(selectedData_Q, 2);
semData_Q = nanstd(selectedData_Q, 0, 2) ./ sqrt(size(selectedData_Q, 2));
figure;
errorbar(1:58, avgData_WT(1:58), semData_WT(1:58));hold on
errorbar(1:58, avgData_Q(1:58), semData_Q(1:58));
xlabel('Day');
ylabel('Avg Pull Speed');
title('Pull Speed (Deg/s) ');






