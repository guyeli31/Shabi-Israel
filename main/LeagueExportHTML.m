%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LEAGUEEXPORTHTML.M — Final version with full bold logic and color maps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mainFile = LeagueExportHTML(Tsum, params, meta)
templatePath = fullfile('templates','template_main.html');
if ~isfile(templatePath)
    error('Missing template: %s', templatePath);
end

mainFile = fullfile(meta.outputFolder, 'league_summary.html');
templateText = fileread(templatePath);

%% ===== Compute min/max for numeric columns =====
numFields = {'Games','Wins','Losses','WinRate','MeanPR','Luck'};
for f = 1:numel(numFields)
    if isnumeric(Tsum.(numFields{f}))
        v = Tsum.(numFields{f});
        minMax.(numFields{f}) = [min(v), max(v)];
    end
end

%% ===== Color functions =====
% General linear color scale
colorNum = @(val,minv,maxv,invert) sprintf('#%02X%02X00', ...
    uint8(255 * (invert * (val - minv)/max(maxv - minv,1e-9) + ...
    (1-invert)*(1 - (val - minv)/max(maxv - minv,1e-9)))), ...
    uint8(255 * ((1-invert)*(val - minv)/max(maxv - minv,1e-9) + ...
    invert*(1 - (val - minv)/max(maxv - minv,1e-9)))));

% Games/Wins/Losses (invert = true for Losses)
function col = gameColor(val,minv,maxv,invert)
    ratio = (val - minv) / max(maxv - minv, 1e-9);
    ratio = min(max(ratio,0),1);
    if invert
        R = uint8(255*ratio);
        G = uint8(255*(1-ratio));
    else
        R = uint8(255*(1-ratio));
        G = uint8(255*ratio);
    end
    col = sprintf('#%02X%02X00',R,G);
end

% Level (MeanPR-based)
colorLevel = @(pr) sprintf('#%02X%02X00', ...
    uint8(255 * min(max((pr-0)/30,0),1)), ...
    uint8(255 * (1 - min(max((pr-0)/30,0),1))));

%% ===== Build HTML table rows =====
tableRows = '';
for i = 1:height(Tsum)
    player = Tsum.Player(i);
    flagCode = meta.FlagCodesSorted{i};

    % Rank color
    if i==1, rankColor='var(--color-gold)';
    elseif i==2, rankColor='var(--color-silver)';
    elseif i>=3 && i<3+params.BronzeCount, rankColor='var(--color-bronze)';
    else, rankColor='transparent'; end

    row = sprintf('<tr><td style="background-color:%s;"><b>%d</b></td>',rankColor,i);
    row = [row sprintf(['<td class="player" data-name="%s" style="background-color:%s;">' ...
        '<img class="flag" src="../../flags/%s.png"> <b><a href="players/%s.html">%s</a></b></td>'], ...
        player, rankColor, flagCode, player, player)];

    % Iterate over data columns
    for f = 3:width(Tsum)
        col = Tsum.Properties.VariableNames{f};
        val = Tsum.(col)(i);

        % ===== LEVEL column =====
        if strcmp(col,'Level')
            pr = Tsum.MeanPR(i);
            c = colorLevel(pr);
            if pr <= 2.5 || pr > 30.0, b1='<b>'; b2='</b>'; else, b1=''; b2=''; end
            row = [row sprintf('<td class="levelCell" style="color:%s;" data-pr="%.2f">%s%s%s</td>', ...
                c, pr, b1, val, b2)];
            continue;
        end

        % ===== Numeric columns =====
        if isnumeric(val)
            invert = strcmp(col,'MeanPR');
            if ismember(col,{'Games','Wins','Losses'})
                invert = strcmp(col,'Losses');
                mm = minMax.(col);
                c = gameColor(val, mm(1), mm(2), invert);
            else
                mm = minMax.(col);
                c = colorNum(val, mm(1), mm(2), invert);
            end

            % ---- Bold detection (min/max) ----
            isExtreme = abs(val - mm(1)) < 1e-9 || abs(val - mm(2)) < 1e-9;
            if ismember(col,{'Games','Wins','Losses'}) && val == 0
                isExtreme = true;
            end
            if isExtreme
                b1='<b>'; b2='</b>';
            else
                b1=''; b2='';
            end

            % ---- Format numeric ----
            if ismember(col, {'Games','Wins','Losses'})
                row = [row sprintf('<td style="color:%s;">%s%.0f%s</td>', c, b1, val, b2)];
            elseif strcmp(col,'WinRate')
                row = [row sprintf('<td style="color:%s;">%s%.2f%%%s</td>', c, b1, val*100, b2)];
            else
                row = [row sprintf('<td style="color:%s;">%s%.2f%s</td>', c, b1, val, b2)];
            end
        else
            row = [row sprintf('<td>%s</td>', val)];
        end
    end
    tableRows = [tableRows row '</tr>' newline];
end

%% ===== Average and Stats rows =====
avgRow = '<tr class="avgRow"><td colspan="2"><b>AVERAGES</b></td>';
for f = 3:width(Tsum)
    col = Tsum.Properties.VariableNames{f};
    if strcmp(col,'Level')
        avgPR = mean(Tsum.MeanPR);
        avgLvl = mapPRtoLevel(avgPR);
        avgRow = [avgRow sprintf('<td style="color:#000;font-weight:bold;">%s</td>', avgLvl)];
    elseif isnumeric(Tsum.(col))
        if ismember(col, {'Games','Wins','Losses'})
            avgRow = [avgRow sprintf('<td style="color:#000;"><b>%.2f</b></td>', mean(Tsum.(col)))];
        elseif strcmp(col,'WinRate')
            avgRow = [avgRow sprintf('<td style="color:#000;"><b>%.2f%%</b></td>', mean(Tsum.(col))*100)];
        else
            avgRow = [avgRow sprintf('<td style="color:#000;"><b>%.2f</b></td>', mean(Tsum.(col)))];
        end
    else
        avgRow = [avgRow '<td></td>'];
    end
end
avgRow = [avgRow '</tr>'];

playedMatches = meta.playedMatches;
totalMatches = meta.totalMatches;
playedRatio = meta.playedRatio * 100;
statRow = sprintf('<tr class="avgRow"><td colspan="9" style="text-align:center;color:#000;">Games Played: %d / %d (%.1f%%)</td></tr>', ...
    playedMatches, totalMatches, playedRatio);

%% ===== Substitute into template =====
htmlOut = templateText;
htmlOut = strrep(htmlOut,'{{LEAGUE_TITLE}}',params.LeagueTitle);
htmlOut = strrep(htmlOut,'{{TABLE_BODY}}',[tableRows avgRow statRow]);
htmlOut = strrep(htmlOut,'{{UPDATED_TIME}}',meta.TimeStamp);

% Back link (relative to root index)
backHTML = [ ...
    '<p style="text-align:center; margin-top:10px;">' ...
    '<a href="../../index.html" style="color:black; text-decoration:none;">⬅ Back to All Leagues</a>' ...
    '</p>' ...
    ];
htmlOut = strrep(htmlOut,'{{BACK_LINK}}',backHTML);

%% ===== Write file =====
fid = fopen(mainFile,'w','n','UTF-8');
fwrite(fid,htmlOut);
fclose(fid);
fprintf('✅ League summary generated: %s\n', mainFile);
end

%% ===== Helper =====
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
