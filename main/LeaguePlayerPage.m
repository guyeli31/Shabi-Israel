%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LEAGUEPLAYERPAGE.M — Restored bold comparison for each pair
%% Highlights best of each (Score / PR / Luck)
%% Keeps correct flag paths and back link
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LeaguePlayerPage(T, Tsum, params, meta)

% --- Normalize column names if needed ---
expected = {'PlayerA','PR_A','Luck_A','Score_A','PlayerB','PR_B','Luck_B','Score_B'};
if width(T)==8 && ~all(strcmp(T.Properties.VariableNames,expected))
    T.Properties.VariableNames = expected;
end

templatePath = fullfile('templates','template_player.html');
if ~isfile(templatePath)
    error('Missing template: %s', templatePath);
end
templateText = fileread(templatePath);

outDir = fullfile(meta.outputFolder,'players');
if ~exist(outDir,'dir'), mkdir(outDir); end

players = string(Tsum.Player);
for i = 1:numel(players)
    p = players(i);
    flag = meta.FlagCodesSorted{i};

    % --- Extract all matches involving this player ---
    sub = T(strcmp(T.PlayerA,p) | strcmp(T.PlayerB,p), :);
    sub(strcmp(sub.PlayerA,'Bye') | strcmp(sub.PlayerB,'Bye'), :) = [];
    if isempty(sub), continue; end

    % --- Align perspectives ---
    selfA = strcmp(sub.PlayerA,p);
    sub.Score_self = sub.Score_A.*selfA + sub.Score_B.*~selfA;
    sub.Score_opp  = sub.Score_B.*selfA + sub.Score_A.*~selfA;
    sub.PR_self    = sub.PR_A.*selfA   + sub.PR_B.*~selfA;
    sub.PR_opp     = sub.PR_B.*selfA   + sub.PR_A.*~selfA;
    sub.Luck_self  = sub.Luck_A.*selfA + sub.Luck_B.*~selfA;
    sub.Luck_opp   = sub.Luck_B.*selfA + sub.Luck_A.*~selfA;
    sub.Opponent   = sub.PlayerB;
    sub.Opponent(~selfA) = sub.PlayerA(~selfA);
    sub = sortrows(sub,'Opponent','ascend');

    % --- Build table rows ---
    rows = '';
    wins = 0;
    for k = 1:height(sub)
        opp = sub.Opponent{k};
        if isfield(params.CustomFlags,opp)
            oppFlag = params.CustomFlags.(opp);
        else
            oppFlag = 'IL';
        end

        % detect unplayed
        isUnplayed = all([sub.PR_self(k),sub.Luck_self(k),sub.Score_self(k), ...
                          sub.PR_opp(k),sub.Luck_opp(k),sub.Score_opp(k)]==0);
        if isUnplayed
            rows = [rows sprintf(['<tr class="unplayed"><td class="player">' ...
                '<img class="flag" src="../../../flags/%s.png"> <b><a href="%s.html">%s</a></b></td>' ...
                '<td></td><td></td><td></td><td></td><td></td><td></td>' ...
                '<td><span>Not played</span></td></tr>'], oppFlag, opp, opp)];
            continue;
        end

        % --- determine result ---
        if sub.Score_self(k) > sub.Score_opp(k)
            cls = 'result-win'; wins = wins + 1;
        elseif sub.Score_self(k) < sub.Score_opp(k)
            cls = 'result-loss';
        else
            cls = 'result-draw';
        end

        % --- BOLDING LOGIC (restored) ---
        % Score: higher wins
        if sub.Score_self(k) > sub.Score_opp(k)
            sSelf = sprintf('<b>%.0f</b>', sub.Score_self(k));
            sOpp  = sprintf('%.0f', sub.Score_opp(k));
        elseif sub.Score_self(k) < sub.Score_opp(k)
            sSelf = sprintf('%.0f', sub.Score_self(k));
            sOpp  = sprintf('<b>%.0f</b>', sub.Score_opp(k));
        else
            sSelf = sprintf('%.0f', sub.Score_self(k));
            sOpp  = sprintf('%.0f', sub.Score_opp(k));
        end

        % PR: lower is better
        if sub.PR_self(k) < sub.PR_opp(k)
            prSelf = sprintf('<b>%.2f</b>', sub.PR_self(k));
            prOpp  = sprintf('%.2f', sub.PR_opp(k));
        elseif sub.PR_self(k) > sub.PR_opp(k)
            prSelf = sprintf('%.2f', sub.PR_self(k));
            prOpp  = sprintf('<b>%.2f</b>', sub.PR_opp(k));
        else
            prSelf = sprintf('%.2f', sub.PR_self(k));
            prOpp  = sprintf('%.2f', sub.PR_opp(k));
        end

        % Luck: higher is better
        if sub.Luck_self(k) > sub.Luck_opp(k)
            lSelf = sprintf('<b>%.2f</b>', sub.Luck_self(k));
            lOpp  = sprintf('%.2f', sub.Luck_opp(k));
        elseif sub.Luck_self(k) < sub.Luck_opp(k)
            lSelf = sprintf('%.2f', sub.Luck_self(k));
            lOpp  = sprintf('<b>%.2f</b>', sub.Luck_opp(k));
        else
            lSelf = sprintf('%.2f', sub.Luck_self(k));
            lOpp  = sprintf('%.2f', sub.Luck_opp(k));
        end

        % --- build row ---
        rows = [rows sprintf(['<tr><td class="player"><img class="flag" src="../../../flags/%s.png"> ' ...
            '<b><a href="%s.html">%s</a></b></td>' ...
            '<td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>' ...
            '<td class="%s">%s</td></tr>'], ...
            oppFlag, opp, opp, sSelf, sOpp, prSelf, prOpp, lSelf, lOpp, cls, upper(strrep(cls,'result-','')))];
    end

    % --- Averages Row (exclude unplayed matches) ---
    isPlayedMask = ~(sub.PR_self==0 & sub.Luck_self==0 & sub.Score_self==0 & ...
                     sub.PR_opp==0 & sub.Luck_opp==0 & sub.Score_opp==0);
    
    if any(isPlayedMask)
        avgPR_self   = mean(sub.PR_self(isPlayedMask));
        avgPR_opp    = mean(sub.PR_opp(isPlayedMask));
        avgLuck_self = mean(sub.Luck_self(isPlayedMask));
        avgLuck_opp  = mean(sub.Luck_opp(isPlayedMask));
        winRate      = wins / sum(isPlayedMask) * 100;
    else
        avgPR_self = 0; avgPR_opp = 0;
        avgLuck_self = 0; avgLuck_opp = 0;
        winRate = 0;
    end
    
    avgRow = sprintf(['<tr class="avgRow"><td><b>AVERAGES</b></td><td></td><td></td>' ...
        '<td><b>%.2f</b></td><td><b>%.2f</b></td>' ...
        '<td><b>%.2f</b></td><td><b>%.2f</b></td>' ...
        '<td><b>%.2f%%</b></td></tr>'], ...
        avgPR_self, avgPR_opp, avgLuck_self, avgLuck_opp, winRate);

    % --- Final HTML substitution ---
    html = templateText;
    html = strrep(html,'{{PLAYER_NAME}}',p);
    html = strrep(html,'{{FLAG_CODE}}',flag);
    html = strrep(html,'{{LEAGUE_TITLE}}',params.LeagueTitle);
    html = strrep(html,'{{MATCH_ROWS}}',[rows avgRow]);
    backHTML = [ ...
    '<p style="text-align:center; margin-top:15px; font-size:18px;">' ...
    '<a href="../league_summary.html" style="color:black; text-decoration:none; font-weight:bold;">⬅ Back to League</a>' ...
    '</p>' ...
    ];
    html = strrep(html,'{{BACK_LINK}}',backHTML);

    % --- Write file ---
    f = fopen(fullfile(outDir,sprintf('%s.html',p)),'w','n','UTF-8');
    fwrite(f,html);
    fclose(f);
end

fprintf('👤 Player pages created (with bold logic): %s\n', outDir);
end
