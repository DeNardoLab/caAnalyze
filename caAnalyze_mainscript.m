%% caAnalyze_mainscript

% INPUTS: (to be placed in a directory for each session to analyze)
    % Directory Containing:
        % 1) 'data_processed' output file from MIN1PIPE
        %    (contining sigfn, dff, and spkfn)
        % 2) Cue information CSVs (csp = tones, us = shocks)
        % 3) Behavior annotations (BehaviorDEPOT 'analyzed' folder)
        % 4a) Timestamp files for miniscope and behCAM
        %   OR
        % 4b) frlu.mat file (containing frame lookup table)
    %  OR
    % Directory of directories with files as described above
    
% OUTPUTS:
    % 1) ROC Analysis Report for cue/behavior cell responses
    % 2) Folders with ROC plot .fig files for each responsive cell analyzed
    % FUTURE: 3) PCA Analysis Report for various trial-averaged / concatenated
    %    cue/behavior assessments of population activity
    % FUTURE: 4) TCA Analysis Report for PCA assessments with trial factors
    % FUTURE: 5) Population Analysis
    % FUTURE: 6) GLM Variance Analysis

%% ADJUSTABLE PARAMETERS
prep_data = 1;
ca_downsample = 2; %Factor by which calcium data was temporally downsampled by
ca_fileID = '*data_processed*';    
csp_ID = 'tones';
us_ID = 'shocks';

run_roc = 0;
sig_label = 'dff';
    
%% Ask for Input Directory and Decide if Single or Batch
% Record base directory
base_dir = pwd;

% Collect data directory
input_dir = uigetdir('Select Directories for Analysis');

cd(input_dir)

% Check for presence of miniscope output file in given data_dir
batch_check = dir(ca_fileID);
analysis_dirs = {};

% If miniscope output detected, turn off batch
if size(batch_check, 1) == 1
    batch = 0;
    analysis_dirs = {input_dir};
% If no miniscope output files detected, turn on batch
elseif size(batch_check, 1) == 0
    batch = 1;
    data_check = dir; data_check(1:2) = [];
    for i = 1 : size(data_check, 1)
        if data_check(i).isdir
            analysis_dirs = [analysis_dirs; data_check(i).folder, addSlash(), data_check(i).name];
        end
    end
end

clearvars batch_check data_check

%% Prep Single/Batch Session
if prep_data
    caAnalyze_prepData(analysis_dirs, ca_downsample, csp_ID, us_ID);
end

if refine_features
    

end

%% Run ROC Analysis

if run_roc
    for i = 1:length(analysis_dirs)
        cd(analysis_dirs{i})
        try
            if exist('rFeatures.mat') > 1
                load('rFeatures.mat')
            else
                load('Features.mat')
            end
            sig_search = dir(ca_fileID);
            S = load(sig_search.name, sig_label);
            signal = S.(sig_label);
            clearvars S sig_search
            caAnalyze_runROC(Features, signal, sig_label)
        end
    end
end
