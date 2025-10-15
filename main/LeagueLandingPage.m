%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LEAGUELANDINGPAGE.M — Adds Leader flag icons and Status column
%% Status is derived from league_params.json field "Running"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LeagueLandingPage(leagues, leagueTables)
templatePath = fullfile('templates','template_index.html');
template = fileread(templatePath);
rows = '';

for i = 1:numel(leagues)
    L = leagues(i);
    % Load parameters to determine Running/Completed
    try
        params = jsondecode(fileread(L.Params));
        if isfield(params,'Running') && params.Running
            status = '<span style="color:green;font-weight:bold;">Running</span>';
        else
            status = '<span style="color:#CC0000;font-weight:bold;">Completed</span>';
        end
    catch
        status = '<span style="color:#888;">Unknown</span>';
    end

    % Leader determination
    if i <= numel(leagueTables)
        Tsum = leagueTables{i};
        if ~isempty(Tsum)
            leaderName = string(Tsum.Player(1));
            leaderFlag = 'IL';
            if isfield(Tsum,'FlagCodesSorted')
                leaderFlag = Tsum.FlagCodesSorted{1};
            elseif isfield(L,'FlagCodesSorted')
                leaderFlag = L.FlagCodesSorted{1};
            end
        else
            leaderName = '(No data)'; leaderFlag='IL';
        end
    else
        leaderName='(Not computed)'; leaderFlag='IL';
    end

    leaguePath = fullfile(L.ID, 'league_summary.html');
    rows = [rows sprintf(['<tr>' ...
        '<td><a href="%s">%s</a></td>' ...
        '<td>%s</td>' ...
        '<td><img class="flag" src="../flags/%s.png"> %s</td></tr>\n'], ...
        leaguePath, L.Title, status, leaderFlag, leaderName)];
end

html = strrep(template,'{{LEAGUE_ROWS}}',rows);
outPath = fullfile('output','index.html');
fid = fopen(outPath,'w','n','UTF-8');
fwrite(fid,html);
fclose(fid);
fprintf('✅ Landing page created with Status column: %s\n',outPath);
end
