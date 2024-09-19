% Script for calculating the Entrance and Performance metrics (Figure 3)
mousenames = ["3QP01","3QP02","3QP03","3QP07","3QP08","3QP09","3QP10",];
for mousename = mousenames
    opts = delimitedTextImportOptions("NumVariables", 5);
    opts.DataLines = [1, Inf];
    opts.Delimiter = "\t";
    opts.VariableNames = ["Date", "EventCode"];
    opts.VariableTypes = ["datetime", "double"];
    opts = setvaropts(opts,'Date','InputFormat','yyyy-MM-dd HH:mm:ss.SSSS'); % Specify datetime format
    opts = setvaropts(opts, 1, "EmptyFieldRule", "auto");
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    DATA = readtable(mousename+"_data.txt", opts);
    clear opts numIdx
    
    while ~exist(mousename+"_DailydataAnalyzed.mat")
        disp("Waiting on the data for "+mousename)
        pause(600)
    end
    load(mousename+"_DailydataAnalyzed.mat");
    
    suc = [3,4]; fail = [53,54];
    
    n =1;
    for i = 2:size(phase,1)
        dur=[];SS=[];SF=[];FS=[];FF=[];Tnum=[];
        while (~(datetime(DATA{n,1},'Format','yyyy-MM-dd')>phase{i,1})) && n<size(DATA,1)-1
            n = n+1;
        end
        while isbetween(datetime(DATA{n,1},'Format','yyyy-MM-dd'),phase{i,1},phase{i,1}+caldays(1))
            n = n+1;
            if (DATA{n,2} == 0) && (n ~= size(DATA,1))
                j=1;events = [];
                while (DATA{n+j,2} ~= 99) && (j+n < size(DATA,1))
                    if nnz(DATA{n+j,2} == suc)
                        events = [events,1];
                    elseif nnz(DATA{n+j,2} == fail)
                        events = [events,0];
                    end
                    j = j+1;
                end
                SS = [SS,nnz(strfind(events,[1 1]))/length(events)];
                SF = [SF,nnz(strfind(events,[1 0]))/length(events)];
                FS = [FS,nnz(strfind(events,[0 1]))/length(events)];
                FF = [FF,nnz(strfind(events,[0 0]))/length(events)];
                dur = [dur, seconds(DATA{n+j,1} - DATA{n,1})];
                if j>1
                    Tnum = [Tnum,j];
                end
                n = n+j;
            end
        end
        SS=[SS,1];FS=[FS,1];SF=[SF,1];FF=[FF,1];
        disp("Day "+num2str(i)+" analysis done!")
        dur = dur(dur>1 & dur<3600);
        phase{i,'Duration'} = nanmean(dur);
        phase{i,'Tr_per_Ent'} = nanmean(Tnum);
        phase{i,'SS'} = nanmean(SS(SS>0))*100;
        phase{i,'SF'} = nanmean(SF(SF>0))*100;
        phase{i,'FS'} = nanmean(FS(FS>0))*100;
        phase{i,'FF'} = nanmean(FF(FF>0))*100;
    end
    save(mousename+"_DailydataAnalyzed.mat","phase")
    clearvars -except mousename mousenames
end