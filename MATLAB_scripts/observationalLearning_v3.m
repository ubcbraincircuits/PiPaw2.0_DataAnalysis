% This script is for calculating the peer influence. Figure 7
% Good influencer -> PotentialLearning
% Bad influencer -> ControlGroup

ControlGroup = cell(0,0);
PotentialLearning = cell(0,0);
pairStrings = [];
pairStrings_control = cell(0,0);
pairStrings_learning = cell(0,0);

for c = 1:9
    cageNumber = c; % Adjust as needed
    filename = ['cage' num2str(cageNumber) '.mat'];
    data = load(filename);
    varName = ['cage' num2str(cageNumber)];
    trials = data.(varName);
    clear data
    % Sort by timestamp
    [~, sortedIdx] = sort([trials{:,1}]);
    trials = trials(sortedIdx, :);
    % Parameters
    minTrials = 10;
    timeWindow = duration(0, 10, 0);
    % Identify all mouse pairs
    allMice = unique(trials(:,8));
    pairs = perms(allMice);
    pairs = pairs(:, 1:2); % keep only the first two columns
    % Initialize results container
    results = containers.Map();
    % Identify success trials
    isSuccess = ismember([trials{:,3}], [3, 4]);
    % Loop over each pair
    for p = 1:size(pairs, 1)
        observingMouse = pairs{p, 1};
        observedMouse = pairs{p, 2};
        pairStr = [observingMouse '-' observedMouse];
        potentialLearning = []; % [baseline, observedMouseRate, observingMouseRate]
        controlGroup = [];
        % Loop through and identify sequences
        for i = (minTrials+1):(length(trials)-minTrials) % leave buffer of minTrials
            currMouse = trials{i,8};
            % Check for 10 trials of current observing mouse within 5 minutes
            if strcmp(currMouse, observedMouse) && trials{i+minTrials-1,1} - trials{i,1}  <= timeWindow && all(strcmp(trials(i:i+minTrials-1,8), currMouse))
                % Find if the observing mouse did 10 trials just before
                prevIdx = find(strcmp(trials(1:i-1,8), observingMouse), minTrials, 'last'); % Last 10 trials of the observing mouse
                postIdx = find(strcmp(trials(i+minTrials:end,8), observingMouse), minTrials, 'first')+i+minTrials-1; % First 10 trials of the observing mouse
                if length(prevIdx) == minTrials && length(postIdx) == minTrials && trials{prevIdx(end),1} - trials{prevIdx(1),1} <= timeWindow && trials{postIdx(end),1} - trials{postIdx(1),1} <= timeWindow && trials{i,1} - trials{prevIdx(end),1} <= timeWindow &&  trials{postIdx(1),1} - trials{i+minTrials-1,1} <= timeWindow
                    % Calculate observing mouse's success rate
                    disp (i)
                    baselineRate = mean(isSuccess(prevIdx));
                    % Calculate observed mouse's baseline and post-observational success rate
                    observedRate = mean(isSuccess(i:i+minTrials-1));
                    postObservRate = mean(isSuccess(postIdx));
                    % Depending on observed rate vs baseline, store data
                    if observedRate > baselineRate
                        potentialLearning = [potentialLearning; baselineRate, observedRate, postObservRate];
                    else
                        controlGroup = [controlGroup; baselineRate, observedRate, postObservRate];
                    end
                end
            end
        end
    % Store potentialLearning and controlGroup in results
    results(pairStr) = struct('PotentialLearning', potentialLearning, 'ControlGroup', controlGroup);
    end

    %pairStr = "6QP12-6QP10";
    %figure();
    %pairStr = "6QP12-6QP10";
    %subplot(8,3,18); bar([mean(results(pairStr).ControlGroup(:,1)), mean(results(pairStr).ControlGroup(:,2)), mean(results(pairStr).ControlGroup(:,3))], 1);hold on;bar([mean(results(pairStr).PotentialLearning(:,1)), mean(results(pairStr).PotentialLearning(:,2)), mean(results(pairStr).PotentialLearning(:,3))], 0.5);title(pairStr);yline(mean(results(pairStr).PotentialLearning(:,1)),'--k')
    % Now you can access the results for each pair using results(pairStr)
    % Initialize tables to store results
    %ControlGroup = [];
    %PotentialLearning = [];
    %pairStrings =[]
    % Loop through each pair

    for p = 1:size(pairs, 1)
        observer = pairs{p, 1};
        observed = pairs{p, 2};
        pairStr = [observer '-' observed];
        % Fetch the results for this pair
        resultMatrix = results(pairStr);
    % Separate data for ControlGroup and PotentialLearning
        controlData = [resultMatrix.ControlGroup];
        learningData = [resultMatrix.PotentialLearning];
    % Calculate the changes for ControlGroup
        ControlGroup = [ControlGroup; controlData];
        ControlGroup{length(ControlGroup),1}(:,4) = ControlGroup{length(ControlGroup),1}(:,2)-ControlGroup{length(ControlGroup),1}(:,1);
        ControlGroup{length(ControlGroup),1}(:,5) = ControlGroup{length(ControlGroup),1}(:,1)-ControlGroup{length(ControlGroup),1}(:,3);
        PotentialLearning = [PotentialLearning; learningData];
        PotentialLearning{length(PotentialLearning),1}(:,4) = PotentialLearning{length(PotentialLearning),1}(:,2)-PotentialLearning{length(PotentialLearning),1}(:,1);
        PotentialLearning{length(PotentialLearning),1}(:,5) = PotentialLearning{length(PotentialLearning),1}(:,1)-PotentialLearning{length(PotentialLearning),1}(:,3);
        pairStrings = [pairStrings;pairStr];
        if size(controlData) > 0
        pairStrings_control = [pairStrings_control; {observer} {observed}];
        end
        if size(learningData) > 0
        pairStrings_learning = [pairStrings_learning; {observer} {observed}];
        end
    end
end

for i = 1:length(ControlGroup)
     ControlGroup{i,1}(:,4) = ControlGroup{i,1}(:,2)-ControlGroup{i,1}(:,1);
     ControlGroup{i,1}(:,5) = ControlGroup{i,1}(:,3)-ControlGroup{i,1}(:,1);
end

for i = 1:length(PotentialLearning)
    PotentialLearning{i,1}(:,4) = PotentialLearning{i,1}(:,2)-PotentialLearning{i,1}(:,1);
    PotentialLearning{i,1}(:,5) = PotentialLearning{i,1}(:,3)-PotentialLearning{i,1}(:,1);
end

wt = [{'6QP01'}; {'6QP02'}; {'6QP05'}; 
    {'6QP06'}; {'6QP08'}; {'6QP12'}; {'6QP15'}; {'6QP17'}; {'6QP18'}; 
    {'6QP19'}; {'6QP23'}; {'6QP24'}; {'6QP25'}; {'6QP26'}];

q175 = [{'6QP07'}; {'6QP09'}; {'6QP10'}; {'6QP11'}; {'6QP13'}; {'6QP14'}; 
    {'6QP16'}; {'6QP20'}; {'6QP21'}; {'6QP22'}];

% Control Plot
figure;
for i = 1:length(ControlGroup)
    tmp = cell2mat(ControlGroup(i,1));
    hold on
    if ismember(pairStrings_control(i,1), q175)
        %s=scatter(tmp(:,4), tmp(:,4), 'filled', 'MarkerFaceColor','r');
        s=swarmchart(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','r');
    else
        %s=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','b');
        s=swarmchart(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','b');
    end
    s.XJitter = 'rand';
    s.XJitterWidth = 0.5;
    s.YJitter = 'rand';
    s.YJitterWidth = 0.5;
    s.MarkerFaceAlpha = 0.5;
end
    xlim([-1.2, 1.2]);
    ylim([-1,1]);
    xlabel('Observed - Baseline');
    ylabel('Baseline - Post Observed');
    title('Control Group');
    h=gobjects(2,1);
    h(1)=scatter(nan,nan,'r','filled');
    h(2)=scatter(nan,nan,'b','filled');
    legend(h, ["Q175 observing" "Wild Type observing"]);
    hold off

% Potential Learning Plot

figure;
for i = 1:length(PotentialLearning)
    tmp = cell2mat(PotentialLearning(i,1));
    hold on
    if ismember(pairStrings_learning(i,1), q175)
        %t=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','r');
        t=swarmchart(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','r');
    else
        %t=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','b');
        t=swarmchart(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','b');
    end
    t.XJitter = 'rand';
    t.XJitterWidth = 0.5;
    t.YJitter = 'rand';
    t.YJitterWidth = 0.5;
    t.MarkerFaceAlpha = 0.5;
end
    wt_only_x = [];
    wt_only_y = [];
    q175_only_x = [];
    q175_only_y = [];
    for i = 1:height(datamlmS3)
    if datamlmS3{i,8} == 'wt'
        wt_only_x = [wt_only_x; datamlmS3{i,4}];
        wt_only_y = [wt_only_y; datamlmS3{i,5}];
    elseif datamlmS3{i,9} == 'q175'
        q175_only_x = [q175_only_x; datamlmS3{i,4}];
        q175_only_y = [q175_only_y; datamlmS3{i,5}];
    end
    end
    mdl_wt = fitlm(wt_only_x, wt_only_y);
    p1 = plot(mdl_wt);
    delete(p1(1));
    delete(p1(3));
    p1(2).LineWidth = 3;
    mdl_q175 = fitlm(q175_only_x, q175_only_y);
    p2 = plot(mdl_q175);
    p2(2).Color = "blue";
    p2(2).LineWidth = 3;
    delete(p2(1));
    delete(p2(3));
    xlim([-1.2, 1.2]);
    ylim([-1,1]);
    xlabel('Observed - Baseline');
    ylabel('Baseline - Post Observed');
    title('Potential Learning');
    h=gobjects(2,1);
    h(1)=scatter(nan,nan,'r','filled');
    h(2)=scatter(nan,nan,'b','filled');
    legend(h, ["Q175 observing" "Wild Type observing"]);
    hold off

    %Both on one plot
figure;
for i = 1:length(ControlGroup)
    tmp = cell2mat(ControlGroup(i,1));
    hold on
    if ismember(pairStrings_control(i,1), wt) && ismember(pairStrings_control(i,2), wt)
        s=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','b');
    elseif ismember(pairStrings_control(i,1), q175) && ismember(pairStrings_control(i,2), q175)
        s=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','r');
    elseif ismember(pairStrings_control(i,1), wt) && ismember(pairStrings_control(i,2), q175)
        s=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','c');
    else
        s=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','m');
    end
    s.XJitter = 'rand';
    s.XJitterWidth = 0.5;
    s.YJitter = 'rand';
    s.YJitterWidth = 0.5;
    s.MarkerFaceAlpha = 0.5;
end

for i = 1:length(PotentialLearning)
    tmp = cell2mat(PotentialLearning(i,1));
    hold on
    if ismember(pairStrings_learning(i,1), wt) && ismember(pairStrings_learning(i,2), wt)
        t=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','b');
    elseif ismember(pairStrings_learning(i,1), q175) && ismember(pairStrings_learning(i,2), q175)
        t=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','r');
    elseif ismember(pairStrings_learning(i,1), wt) && ismember(pairStrings_learning(i,2), q175)
        t=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','c');
    else
        t=scatter(tmp(:,4), tmp(:,5), 'filled', 'MarkerFaceColor','m');
    end
    t.XJitter = 'rand';
    t.XJitterWidth = 0.5;
    t.YJitter = 'rand';
    t.YJitterWidth = 0.5;
    t.MarkerFaceAlpha = 0.5;
end
    xlim([-1.2, 1.2]);
    ylim([-1,1]);
    xlabel('Observed - Baseline');
    ylabel('Baseline - Post Observed');
    title('All');
    h=gobjects(4,1);
    h(1)=scatter(nan,nan,'r','filled');
    h(2)=scatter(nan,nan,'b','filled');
    h(3)=scatter(nan,nan,'m','filled');
    h(4)=scatter(nan,nan,'c','filled');
    legend(h, ["Q-Q" "W-W" "Q-W" "W-Q"]);
    hold off