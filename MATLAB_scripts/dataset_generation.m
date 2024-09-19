
wt = ["3QP02","3QP03","3QP10"];
q175 = ["3QP01","3QP07","3QP08","3QP09"];
mice = [wt,q175];
% stnd = NaN(150,24); T2T=NaN(150,24);HPass=NaN(150,24);
% Dur=NaN(150,24);Tr=NaN(150,24);
totWater = NaN(60,length(mice));totTrials=NaN(60,length(mice));
for i = 1:length(mice)
    mouse = mice(i);
    load(mouse+'_DailydataAnalyzed.mat');
    t = length(phase{2:end,'std'});
%      for j = 2:t
%          if phase{j,'RewP'}>100
%              phase{j,'Water'} = phase{j,'RewP'};
%          else
%              phase{j,'Water'} = 100-phase{j,'freeW'};
%          end
%      end
    totWater(1:t,i) = phase{2:end,'Water'};
    totTrials(1:t,i)= phase{2:end,'RewP'}+phase{2:end,'FailP'};
    stnd(1:t,i) = phase{2:end,'std'};
    T2T(1:t,i) = phase{2:end,'T2TCorr'};
    HPass(1:t,i) = phase{2:end,'HPassVariabality'};
    Dur(1:t,i) = phase{2:end,"Duration"};
    Tr(1:t,i) = phase{2:end,"Tr_per_Ent"};
    SS(1:t,i) = phase{2:end,"SS"};
    SF(1:t,i) = phase{2:end,"SF"};
    FS(1:t,i) = phase{2:end,"FS"};
    FF(1:t,i) = phase{2:end,"FF"};
    save(mouse+'_DailydataAnalyzed.mat',"phase")
    clear phase
end