% Script for generating the datasets, cleaning data and preprocessing the
% raw files
mousenames = ["3QP03","3QP07","3QP08","3QP09","3QP10",];
ct=0;
wbar = 1/length(mousenames);
k=10;
f = waitbar(wbar*ct+wbar/k,['Starting... ',char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);
for mousename = mousenames
    %% DATA Import
    %holdtime data import
    disp("Importing Data...")
    wbar = 1/length(mousenames);
    k=10;waitbar(wbar*ct+wbar/k,f,['Loading Data for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);

    opts = delimitedTextImportOptions("NumVariables", 5);
    opts.DataLines = [1, Inf];
    opts.Delimiter = "\t";
    opts.VariableNames = ["Date", "EventCode", "ReqHold", "HoldT","PertForce"];
    opts.VariableTypes = ["datetime", "double", "double", "double","double"];
    opts = setvaropts(opts,'Date','InputFormat','yyyy-MM-dd HH:mm:ss.SSSS'); % Specify datetime format
    opts = setvaropts(opts, 1, "EmptyFieldRule", "auto");
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    DATA = readtable(mousename+"_data.txt", opts);
    DATA = table2cell(DATA);
    numIdx = cellfun(@(x) ~isnan(str2double(x)), DATA);
    DATA(numIdx) = cellfun(@(x) {str2double(x)}, DATA(numIdx));
    clear opts numIdx
    opts = delimitedTextImportOptions("NumVariables", 9);
    opts.DataLines = [1, Inf];
    opts.Delimiter = "\t";
    opts.VariableNames = ["Date", "RewP", "FailP", "mean", "med", "q3", "ht", "freeW", "phase","std","T2TCorr","HPassVariabality","T2TCorr>.1"];
    opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts = setvaropts(opts, 1, "InputFormat", "yyyy-MM-dd");
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    phase = readtable(mousename+"_dailyreport.txt", opts);
    clear opts
    
    %Importing the position data as a cell array
    k=9;waitbar(wbar*ct+wbar/k,f,['Loading Lever Positions for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);
    opts = delimitedTextImportOptions("NumVariables", 2);
    opts.VariableTypes = ["char", "char"];
    opts.Delimiter = '\t';
    positions = readtable(mousename+"_leverPos.txt",opts);
    position = table2cell(positions);
    clear opts positions
    
    %% Writing Data to Cell Arrays
    % Find the rows with datetime objects on them
    k=8;waitbar(wbar*ct+wbar/k,f,['Finding rows with datetime objects for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);

    dateLines = regexp(position,'.*:.*','match','once');
    dateLineMask = ~cellfun(@isempty, dateLines);
    
    % Make blocks with the datetime string in the first cell
    blocks = cell(nnz(dateLineMask),6);
    blocks(:,1) = position(dateLineMask);
    % And the numbers in an array in the second cell
    dateLineNos = [find(dateLineMask); length(position)+1];
    for i = 1:length(dateLineNos)-1
        inds = dateLineNos(i)+1 : dateLineNos(i+1)-1;
        blocks{i,2} = str2double(position(inds,:));
    end
    clear dateLines dateLineMask bothNumbers dateLineNos tlines tline numldx fpos inds
    % 2 modifications should be done to the position data: 
    % 1-position conversion to degrees
    % 2- time conversion to negative values before trial start
    k=7;waitbar(wbar*ct+wbar/k,f,['Modifying Position Data for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);

    for i=1:length(blocks)
        blocks{i,2}(:,2)= (blocks{i,2}(:,2)/4096)*360;
        n = nnz(blocks{i,2}(:,1)==0);
        blocks{i,2}(1:n,1) = blocks{i,2}(1:n,1)-fliplr((1:n)/400)'; 
    end
    % Converting strings in the position blocks to datetime format
    for i = 1:length(blocks)
        if ~contains(blocks{i,1},'.')
            blocks{i,1}=[blocks{i,1},'.0000'];
        end
        blocks{i,1} = datetime(strip(blocks{i,1},char(0)),'InputFormat','yyyy-MM-dd HH:mm:ss.SSSS');
    end
    % Adding Holdtime and Event Codes to Blocks of Position data
    k=6;waitbar(wbar*ct+wbar/k,f,['Adding Holdtime and Event Codes for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);
    cntr = 0;
    for i = 1:length(blocks)
        for j = cntr+1 : length(DATA)
            if blocks{i,1}==DATA{j,1}
                blocks{i,3} = DATA{j,2}; %Adding Event Codes
                blocks{i,4} = DATA{j,4}; %Adding Hold time
                blocks{i,5} = DATA{j,3}; %Adding Required Hold time
                blocks{i,6} = DATA{j,5}; %Adding Perturbation Force
                cntr = j;
                break
                
            end
        end
    end
    n = 1; %Adding phase from dailyreport file
    k=5;waitbar(wbar*ct+wbar/k,f,['Adding phase from dailyreport file for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);
    for i = 1:height(phase)
        while blocks{n,1}.Day == phase{i,1}.Day && blocks{n,1}.Month == phase{i,1}.Month
            blocks{n,7} = phase{i,9};
            n = n+1;
        end
    end 
    disp(mousename+" Data imported. Initiating data cleaning...")
    
    %% Cleaning the data
    k=4;waitbar(wbar*ct+wbar/k,f,['Cleaning Data for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);
    n = 1; %cleaning short trials and phase 1 trials
    while n<length(blocks)-1
        while isempty(blocks{n,4}) || blocks{n,4}<.01 || blocks{n,4}>3 || blocks{n,3}<3 
            blocks(n,:) = [];
            if n>size(phase,2)
                break
            end
        end
        n = n+1;
    end
    
    n = 1;
    while n<length(blocks)-1
        while nnz(~diff(blocks{n,2}(blocks{n,2}(:,1)>0,2)))==0
                blocks(n,:) = [];
                if n>size(phase,2)
                    break
                end
        end
        n = n+1;
    end
    
    n = 1;
    while n<length(blocks)-1
        while blocks{n,2}(1,2)>6 || nnz(blocks{n,2}(:,2)<0)>0
            blocks(n,:) = [];
            if n>size(phase,2)
                break
            end
        end
        n = n+1;
    end
    % cleaning phase
    n=1;
    while n<size(phase,1)-1
        while (phase{n,9}<2 || phase{n,2}<10 )
            phase(n,:) = [];
            if n>size(phase,2)
                break
            end
        end
        n = n+1;
    end
    %% Daily Variables 
    k=3;waitbar(wbar*ct+wbar/k,f,['Calculating Daily Variables for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);
    n =1;
    for i = 2:size(phase,1)
        stnd =0;t2t=0;stdH = 0;
        while (~(datetime(blocks{n,1},'Format','yyyy-MM-dd')>phase{i,1})) && n<length(blocks)-2
            n = n+1;
        end
        while (isbetween(datetime(blocks{n,1},'Format','yyyy-MM-dd'),phase{i,1},phase{i,1}+caldays(1))) && n<length(blocks)-1
            n = n+1;
            stnd = [stnd,std(blocks{n,2}(:,2))];
            a = blocks{n,2}((blocks{n,2}(:,1)>0),2);b = blocks{n+1,2}((blocks{n+1,2}(:,1)>0),2);
            if length(a) > 2 && length(b)>2
                c = corr(a(1:min(length(a),length(b))),b(1:min(length(a),length(b))));
                t2t = [t2t,c];
                if length(blocks{n,2}(:,2))>10
                    stdH = [stdH,std(highpass(normalize(blocks{n,2}(:,2)),10,400))];
                end
            end
        end
        disp("Day "+num2str(i)+" analysis done!")
        phase{i,10} = nanmean(stnd);
        phase{i,11} = nanmean(t2t);
        phase{i,12} = nanmean(stdH);
    end
    k=2;waitbar(wbar*ct+wbar/k,f,['Saving DailydataAnalyzed.mat file for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);
    save(mousename+"_DailydataAnalyzed.mat","phase")
    k=1;waitbar(wbar*ct+wbar/k,f,['Saving Blocks.mat file for ',char(mousename),char(10),' (',char(string(round((wbar*ct+wbar/k)*100,1))),'%)']);
    save(mousename+"_Blocks.mat","blocks")
    ct=ct+1;
    clearvars -except mousenames mousename ct f

end


