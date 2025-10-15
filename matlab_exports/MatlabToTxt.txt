%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EXPORT_MATLAB_FILES_AS_TEXT.M
%% Scans current folder recursively, reads all .m files, and saves their
%% contents as .txt files in a separate "matlab_exports" folder.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;

%% ====== 1. PARAMETERS ======
baseDir = pwd;                           % Current directory
exportDir = fullfile(baseDir, 'matlab_exports');

if ~isfolder(exportDir)
    mkdir(exportDir);
end

%% ====== 2. FIND ALL .M FILES ======
mFiles = dir(fullfile(baseDir, '**', '*.m')); % Recursive search

fprintf('Found %d MATLAB files.\n', numel(mFiles));

%% ====== 3. EXPORT EACH FILE ======
for k = 1:numel(mFiles)
    srcPath = fullfile(mFiles(k).folder, mFiles(k).name);
    [~, baseName] = fileparts(mFiles(k).name);
    destPath = fullfile(exportDir, [baseName '.txt']);
    
    % Read file content
    fid = fopen(srcPath, 'r');
    if fid < 0
        warning('Could not open %s', srcPath);
        continue;
    end
    textContent = fread(fid, '*char')';
    fclose(fid);
    
    % Write to text file
    fid = fopen(destPath, 'w');
    if fid < 0
        warning('Could not write %s', destPath);
        continue;
    end
    fwrite(fid, textContent, 'char');
    fclose(fid);
    
    fprintf('✔ Exported: %s → %s\n', mFiles(k).name, destPath);
end

fprintf('\nAll MATLAB files exported to: %s\n', exportDir);
