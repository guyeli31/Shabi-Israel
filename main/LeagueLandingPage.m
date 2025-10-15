%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LEAGUELANDINGPAGE.M — Root Index Version (Fixed)
%% Generates /index.html at project root
%% All paths relative to root (output/, flags/, assets/)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LeagueLandingPage(leagues, leagueTables)
templatePath = fullfile('templates','template_index.html');
template = fileread(templatePath);
rows = '';

for i = 1:numel(leagues)
    L = leagues(i);

    % Determine status from league_params.json
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

    % Leader extraction
    leaderName = '(No data)';
    leaderFlag = 'IL';
    if i <= numel(leagueTables)
        Tsum = leagueTables{i};
        if ~isempty(Tsum)
            leaderName = string(Tsum.Player(1));
            if isfield(leagues(i), 'FlagCodesSorted')
                leaderFlag = leagues(i).FlagCodesSorted{1};
            elseif isfield(Tsum, 'FlagCodesSorted')
                leaderFlag = Tsum.FlagCodesSorted{1};
            end
        end
    end

    % Path to each league (now relative to root)
    leaguePath = fullfile('output', L.ID, 'league_summary.html');
    rows = [rows sprintf(['<tr>' ...
        '<td><a href="%s">%s</a></td>' ...
        '<td>%s</td>' ...
        '<td><img class="flag" src="flags/%s.png"> %s</td></tr>\n'], ...
        leaguePath, L.Title, status, leaderFlag, leaderName)];
end

% Insert into template
html = strrep(template,'{{LEAGUE_ROWS}}',rows);

% Save to root folder
outPath = fullfile(pwd,'index.html');
fid = fopen(outPath,'w','n','UTF-8');
fwrite(fid,html);
fclose(fid);

fprintf('✅ Root landing page created successfully: %s\n', outPath);
end
