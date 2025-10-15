%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LEAGUE_PARAMS
%% Load configuration from league_params.json
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function params = LeagueParams(jsonPath)

if ~isfile(jsonPath)
    error('League parameter file not found: %s', jsonPath);
end

txt = fileread(jsonPath);
try
    raw = jsondecode(txt);
catch
    error('Invalid JSON format in %s', jsonPath);
end

%% ---- Required Fields ----
if ~isfield(raw,'LeagueTitle')
    warning('Missing LeagueTitle, using default');
    raw.LeagueTitle = 'League Table';
end

if ~isfield(raw,'BronzeCount')
    raw.BronzeCount = 4;
end

if ~isfield(raw,'CustomFlags')
    raw.CustomFlags = struct();
end

%% ---- Return Struct ----
params.LeagueTitle = raw.LeagueTitle;
params.BronzeCount = raw.BronzeCount;
params.CustomFlags = raw.CustomFlags;

end
