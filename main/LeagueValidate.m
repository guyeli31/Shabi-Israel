%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LEAGUEVALIDATE.M — Validates all league folders under /leagues
%% Prints terminal report + saves HTML summary to /output/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LeagueValidate()
clc;
fprintf('=============================\n');
fprintf(' LEAGUE VALIDATION REPORT\n');
fprintf('=============================\n\n');

baseDir = fullfile(pwd, 'leagues');
if ~isfolder(baseDir)
    error('Folder "leagues" not found.');
end

folders = dir(baseDir);
folders = folders([folders.isdir] & ~ismember({folders.name},{'.','..'}));
if isempty(folders)
    fprintf('No league folders found in "%s".\n', baseDir);
    return;
end

results = struct([]);
totalValid = 0;

for i = 1:numel(folders)
    LID = folders(i).name;
    Lpath = fullfile(baseDir, LID);
    csvFile = fullfile(Lpath, 'leaguedata.csv');
    paramFile = fullfile(Lpath, 'league_params.json');

    validCSV = isfile(csvFile);
    validJSON = isfile(paramFile);
    jsonOK = false; titleOK = false; bronzeOK = false;

    if validJSON
        try
            data = jsondecode(fileread(paramFile));
            jsonOK = true;
            if isfield(data,'LeagueTitle'), titleOK = true; end
            if isfield(data,'BronzeCount'), bronzeOK = true; end
        catch
            jsonOK = false;
        end
    end

    leagueValid = validCSV && validJSON && jsonOK && titleOK && bronzeOK;
    if leagueValid, totalValid = totalValid + 1; end

    results(i).ID = LID;
    results(i).Valid = leagueValid;
    results(i).CSV = validCSV;
    results(i).JSON = validJSON;
end

for i = 1:numel(results)
    r = results(i);
    status = ternary(r.Valid,'✅ OK','❌ INVALID');
    fprintf('%-20s %s\n', r.ID, status);
end
fprintf('\nSummary: %d / %d valid.\n', totalValid, numel(results));

% HTML report
outDir = fullfile('output');
if ~exist(outDir,'dir'), mkdir(outDir); end
htmlPath = fullfile(outDir,'validation_report.html');
fid = fopen(htmlPath,'w','n','UTF-8');
fprintf(fid,'<!DOCTYPE html><html><head><meta charset="UTF-8"><title>League Validation</title>');
fprintf(fid,'<style>body{font-family:Arial;background:#f4f7fa;}table{border-collapse:collapse;margin:auto;}td,th{border:1px solid #ddd;padding:6px;text-align:center;}th{background:#B7DEE8;}</style></head><body><h1 style="text-align:center;">League Validation Report</h1><table><tr><th>League</th><th>Status</th></tr>');
for i = 1:numel(results)
    r = results(i);
    fprintf(fid,'<tr><td>%s</td><td style="color:%s;font-weight:bold;">%s</td></tr>', ...
        r.ID, ternary(r.Valid,'green','red'), ternary(r.Valid,'OK','INVALID'));
end
fprintf(fid,'</table></body></html>');
fclose(fid);
fprintf('📄 HTML report saved: %s\n\n', htmlPath);
end

function out=ternary(cond,a,b)
if cond, out=a; else, out=b; end
end
