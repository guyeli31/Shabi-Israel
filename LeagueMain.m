%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LEAGUEMAIN.M — FINAL MULTI-LEAGUE BUILDER
%% Auto-discovers all leagues under /leagues and generates:
%% - Individual HTML outputs per league
%% - Player pages with relative assets
%% - Global landing page with leaders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LeagueMain()
clc; clear; close all;

fprintf('=========================================\n');
fprintf('  SHABI ISRAEL LEAGUE SYSTEM - STARTING\n');
fprintf('=========================================\n\n');

%% ====== 1. AUTO-DISCOVER LEAGUES ======
leaguesDir = fullfile(pwd, 'leagues');
if ~isfolder(leaguesDir)
    error('Folder "leagues" not found in %s', pwd);
end

folders = dir(leaguesDir);
folders = folders([folders.isdir] & ~ismember({folders.name},{'.','..'}));

if isempty(folders)
    error('No leagues found under "%s".', leaguesDir);
end

leagues = struct([]);
for i = 1:numel(folders)
    LID = folders(i).name;
    Lpath = fullfile(leaguesDir, LID);
    csvFile = fullfile(Lpath, 'leaguedata.csv');
    paramFile = fullfile(Lpath, 'league_params.json');

    if ~isfile(csvFile) || ~isfile(paramFile)
        warning('Skipping "%s" (missing required files).', LID);
        continue;
    end

    params = jsondecode(fileread(paramFile));
    leagues(end+1).ID = LID; %#ok<SAGROW>
    leagues(end).Title = params.LeagueTitle;
    leagues(end).CSV = csvFile;
    leagues(end).Params = paramFile;
end

if isempty(leagues)
    error('No valid leagues with both CSV + JSON found.');
end

fprintf('Detected %d leagues.\n', numel(leagues));


%% ====== 2. VALIDATION STAGE ======
try
    LeagueValidate();
catch ME
    fprintf('⚠ Validation skipped due to: %s\n', ME.message);
end

% ====== 3. Optional: Load order file ======
orderFile = fullfile(pwd,'leagues_order.json');
useCustomOrder = false;

if isfile(orderFile)
    try
        orderData = jsondecode(fileread(orderFile));
        if isfield(orderData,'DisplayOrder')
            titlesFromFile = string(orderData.DisplayOrder(:));
            titlesFromLeagues = string({leagues.Title});

            % Check for consistency
            if numel(titlesFromFile) ~= numel(titlesFromLeagues) || ...
               ~all(ismember(titlesFromLeagues,titlesFromFile))
                warning('⚠️ leagues_order.json ignored: mismatch between file titles and loaded leagues.');
            else
                [~, idx] = ismember(titlesFromFile, titlesFromLeagues);
                leagues = leagues(idx);
                useCustomOrder = true;
                fprintf('📑 Leagues ordered according to leagues_order.json.\n');
            end
        else
            warning('⚠️ Invalid format in leagues_order.json (missing "DisplayOrder"). Using default order.');
        end
    catch ME
        warning('⚠️ Failed to parse leagues_order.json (%s). Using default order.', ME.message);
    end
else
    fprintf('ℹ️ leagues_order.json not found. Using alphabetical order.\n');
end

%% ====== 3. BUILD EACH LEAGUE ======
leagueTables = cell(1,numel(leagues));

for i = 1:numel(leagues)
    L = leagues(i);
    fprintf('\n=== Building %s ===\n', L.Title);

    params = LeagueParams(L.Params);
    T = LeagueLoadData(L.CSV);
    Stats = LeagueComputeStats(T);
    [Tsum, meta] = LeagueBuildTables(Stats, params);
    leagueTables{i} = Tsum;
    
    % --- Create League Output Folder ---
    outputFolder = fullfile('output', L.ID);
    if ~exist(outputFolder,'dir'), mkdir(outputFolder); end
    meta.outputFolder = outputFolder;

    % --- Copy Assets (CSS, JS) Locally ---
    srcAssets = fullfile('assets');
    dstAssets = fullfile(outputFolder,'assets');
    if ~exist(dstAssets,'dir'), mkdir(dstAssets); end
    copyfile(fullfile(srcAssets,'style.css'), dstAssets);
    copyfile(fullfile(srcAssets,'sortTable.js'), dstAssets);

    % --- Generate HTML Files ---
    mainFile = LeagueExportHTML(Tsum, params, meta);
    meta.mainFile = mainFile;
    LeaguePlayerPage(T, Tsum, params, meta);

    fprintf('✅ %s built successfully.\n', L.Title);
end

%% ====== 4. COPY GLOBAL ASSETS FOR LANDING PAGE ======
srcAssets = fullfile('assets');
dstAssetsRoot = fullfile('output','assets');
if ~exist(dstAssetsRoot,'dir')
    mkdir(dstAssetsRoot);
end
copyfile(fullfile(srcAssets,'style.css'), dstAssetsRoot);
copyfile(fullfile(srcAssets,'sortTable.js'), dstAssetsRoot);

%% ====== 5. BUILD LANDING PAGE ======
LeagueLandingPage(leagues, leagueTables);
fprintf('\n🏁 All leagues processed successfully.\n');
end
