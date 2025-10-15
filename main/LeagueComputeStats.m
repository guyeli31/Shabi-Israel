%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LEAGUE_COMPUTESTATS
%% Compute player-level statistics from match CSV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Stats = LeagueComputeStats(T)
%% ========== CLEAN INPUT ==========
T.Properties.VariableNames = {'PlayerA','PR_A','Luck_A','Score_A',...
                              'PlayerB','PR_B','Luck_B','Score_B'};

isHeader = strcmpi(T.PlayerA,'Player') | strcmpi(T.PlayerA,'');
isBye = strcmpi(T.PlayerA,'Bye') | strcmpi(T.PlayerB,'Bye');
isUnplayed = (T.PR_A==0 & T.Luck_A==0 & T.Score_A==0 & ...
              T.PR_B==0 & T.Luck_B==0 & T.Score_B==0);

T = T(~isHeader & ~isBye & ~isUnplayed,:);

%% ========== GET UNIQUE PLAYERS ==========
players = unique([T.PlayerA; T.PlayerB]);
Stats = struct();

%% ========== COMPUTE STATS PER PLAYER ==========
for i = 1:numel(players)
    p = players{i};
    idxA = strcmp(T.PlayerA,p);
    idxB = strcmp(T.PlayerB,p);
    
    pr_self   = [T.PR_A(idxA);  T.PR_B(idxB)];
    luck_self = [T.Luck_A(idxA); T.Luck_B(idxB)];
    score_self= [T.Score_A(idxA); T.Score_B(idxB)];
    pr_opp    = [T.PR_B(idxA);  T.PR_A(idxB)];
    luck_opp  = [T.Luck_B(idxA); T.Luck_A(idxB)];
    score_opp = [T.Score_B(idxA); T.Score_A(idxB)];
    
    wins   = sum(score_self > score_opp);
    losses = sum(score_self < score_opp);
    nGames = wins + losses;
    if nGames == 0, continue; end

    % Core metrics
    S.Games      = nGames;
    S.Wins       = wins;
    S.Losses     = losses;
    S.WinRate    = wins / nGames;
    S.MeanPR     = mean(pr_self);
    S.HighestPR  = max(pr_self);
    S.LowestPR   = min(pr_self);
    S.OppMeanPR  = mean(pr_opp);
    S.Luck       = mean(luck_self - luck_opp);

    Stats.(p) = S;
end
end
