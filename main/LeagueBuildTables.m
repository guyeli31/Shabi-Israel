%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LEAGUEBUILDTABLES.M — Adds LEVEL column and computes safe averages
%% Converts MeanPR into Level (World Champ → Distracted)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Tsum, meta] = LeagueBuildTables(Stats, params)

%% ========== BUILD TABLE ==========
names = fieldnames(Stats);
N = numel(names);
Tsum = table('Size',[N 9], ...
    'VariableTypes',{'double','string','double','double','double','double','double','string','double'}, ...
    'VariableNames',{'Rank','Player','Games','Wins','Losses','WinRate','MeanPR','Level','Luck'});

flagCodes = cell(N,1);
for i = 1:N
    p = names{i};
    row = Stats.(p);
    if isfield(params.CustomFlags, p)
        flagCode = params.CustomFlags.(p);
    else
        flagCode = 'IL';
    end

    Tsum.Player(i)     = string(p);
    Tsum.Games(i)      = row.Games;
    Tsum.Wins(i)       = row.Wins;
    Tsum.Losses(i)     = row.Losses;
    Tsum.WinRate(i)    = row.WinRate;
    Tsum.MeanPR(i)     = row.MeanPR;
    Tsum.Level(i)      = mapPRtoLevel(row.MeanPR);
    Tsum.Luck(i)       = row.Luck;
    flagCodes{i} = flagCode;
end

%% ========== SORT TABLE ==========
[Tsum, sortIdx] = sortrows(Tsum, {'WinRate','MeanPR'}, {'descend','ascend'});
Tsum.Rank = (1:height(Tsum))';
flagCodesSorted = flagCodes(sortIdx);

%% ========== META ==========
playedMatches = sum(Tsum.Games)/2;
totalMatches = nchoosek(N,2);
playedRatio = playedMatches / totalMatches;

meta.FlagCodesSorted = flagCodesSorted;
meta.TotalPlayers = N;
meta.TimeStamp = datestr(now,'yyyy-mm-dd HH:MM');
meta.BronzeCount = params.BronzeCount;
meta.playedMatches = round(playedMatches);
meta.totalMatches = totalMatches;
meta.playedRatio = playedRatio;

% mean only for numeric columns
numVars = varfun(@isnumeric, Tsum(:,3:end), 'OutputFormat','uniform');
meta.MeanValues = varfun(@mean, Tsum(:,3:end), 'InputVariables', ...
    Tsum.Properties.VariableNames(2+find(numVars)));

end

%% ================= HELPER =================
function lvl = mapPRtoLevel(pr)
if pr <= 2.5, lvl = "World Champ";
elseif pr <= 5, lvl = "World Class";
elseif pr <= 7.5, lvl = "Expert";
elseif pr <= 12.5, lvl = "Advanced";
elseif pr <= 17.5, lvl = "Intermediate";
elseif pr <= 22.5, lvl = "Casual Player";
elseif pr <= 30.0, lvl = "Beginner";
else, lvl = "Distracted";
end
end
