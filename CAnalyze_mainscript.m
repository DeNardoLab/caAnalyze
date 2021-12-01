%% CAnalyze_mainscript

% INPUTS: (to be placed in a directory for each session to analyze)
    % Directory Containing:
        % 1) 'data_processed' output file from MIN1PIPE
        %    (contining sigfn, dff, and spkfn)
        % 2) Cue information (tones, shocks)
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

%% Adjustable Parameters

ca_downsample = 2; %Factor by which calcium data was temporally downsampled by
    
    
%% Ask for Input Directory and Decide if Single or Batch
% Record base directory
base_dir = pwd;

% Collect data directory
input_dir = uigetdir('Select Directories for Analysis');

cd(input_dir)

% Check for presence of miniscope output file in given data_dir
batch_check = dir('*data_processed*');
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

for n = 1:size(analysis_dirs, 1)
    
    current_data_dir = analysis_dirs{n};
    cd(current_data_dir)
    
    % Register files in current_data_dir
    behDepot_search = dir('*_analyzed*');
    ca_search = dir('*data_processed*');
    cue_search = dir('*_*-*-*_*-*-*.mat');
    ts_search = dir('*timeStamps*.csv');
    frlu_search = dir('*frlu*.mat');
    % Cues_search = dir('*Cues*.mat');
    
    skip = 0;
   
    % If BehDepot output and calcium data are successfully detected
    if size(behDepot_search, 1) == 1 && size(ca_search, 1) == 1 && size(cue_search, 1) == 1
        if size(frlu_search, 1) == 1
            use_frlu = 1;
            frlu_file = frlu_search.name;
        else
            if size(ts_search, 1) == 2
                use_frlu = 0;
                ts1 = ts_search(1).name;
                ts2 = ts_search(2).name;
                % Sort timestamp files into miniscope and behavior
                if contains(ts1, 'v4', 'IgnoreCase', true) || contains(ts1, 'ms', 'IgnoreCase', true)
                    ms_ts_file = ts1;
                    beh_ts_file = ts2;
                elseif contains(ts2, 'v4', 'IgnoreCase', true) || contains(ts2, 'ms', 'IgnoreCase', true)
                    ms_ts_file = ts2;
                    beh_ts_file = ts1;
                end
            else
               skip = 1; 
            end
        end
            
    else
        skip = 1;
    end
    
    if skip == 1
        % Skip folder if skip is triggered
        disp('BehDepot output, cues data, and/or calcium traces not detected for this session')
        disp('Skipping folder') 
    
    % Otherwise, run main analysis script
    else
        % Set required files aquired through search
        behDepot_dir = behDepot_search.name;
        ca_file = ca_search.name;
        cue_file = cue_search.name;
        
        clearvars behDepot_search ca_search cue_search frlu_search ts_search
%% Load Calcium Data

        % Load signals from output file
        signals = load(ca_file, 'sigfn', 'dff', 'spkfn');
        total_ca_frames = size(sigfn, 2);
        
%% Load Cue Script
        
        % Find and load cue file
        try
            load(cue_file, 'cueframes')
            cueframes;
            clearvars cueframes
        catch
            % Generate cueframes if not already present
            datetime = input('Enter video timestamp', 's')
            calcCueFrames(cue_file, 30, datetime);
            load(cue_file, 'cueframes')
            cueframes;
            clearvars cueframes
        end


%% Make general cue vectors (currently, tones (csp) and shocks (us))
        Cues = genCueStruct(cue_file, total_ca_frames, ca_downsample);

%% Load BehaviorDEPOT output data
        cd(behDepot_dir)
        load('Behavior.mat')
        load('Behavior_Filter.mat')
        load('Metrics.mat')
        cd(current_data_dir)
        
%% Load and/or generate frlu
        % Prompt generation of lookup table, if not found
        if use_frlu == 0  
            f_tbl = prepFrluData(ms_ts_file, beh_ts_file);
            [frlu, frlu_cols] = createFrlu(f_tbl, ca_downsample);

            % Save lookup table at same path as v4 timestamps
            save('frlu.mat', 'frlu', 'frlu_cols')
        else
            load(frlu_file);
        end
        
%% Generate caBehavior Struct to Hold Aligned Behavior Data
        caBehavior = beh2Mini(Behavior, Behavior_Filter, Metrics, frlu, total_ca_frames);
        
%% Make Vectors for Combined Cues / Behaviors
        
        % Combine all cue & behavior vectors and save in Features
        Features = genFeatures(Cues, caBehavior);
        
%% Segment tone/shock cues into learning periods (for v4PMA settings)
        
        % Collect labels for behavior session (learning / retrieval)
        Cues = getSessionLabels(Cues);
        
        % Make vectors in Features for each session period
        Features = applySession(Cues, Features);

        % Generate a list of Vectors from caBehavior to test on ROC
        features = fieldnames(Features);

%% Run ROC Analysis on all Relevant Vectors
        
        ROC_Log = table();
        
        % Organize vectors to cycle through & cooresponding output folder names
        for i = 1:3
            sig_labels = fieldnames(signals);
            sig = signals.(sig_labels{i});
            
            sig_log = struct();
            
            for ii = 1:size(features, 1)
                eventmat = Features.(features{ii})';
                session_name = [sig_labels{i}, '_' features{ii}];
        
                % Loop through ROC analysis script, saving data in appropriate folders
                [n_excited, n_suppressed, auc_n, percent_excited, percent_suppressed]...
                 = caROC(sig, eventmat, session_name);
                
                % Store run data in a temp log
                Signal = sig_labels(i);
                Vector = features(ii);
                Excited = [n_excited, percent_excited];
                Suppressed = [n_suppressed, percent_suppressed];
                ROC_Log = vertcat(ROC.Log, table(Signal, Vector, Excited, Suppressed));
                
            end
        end
    
    % Save session data to log struct
    save('Features.mat', 'Features')
    save('ROC_Log.mat', 'ROC_Log')
    
    % Loop to next session in analysis_dirs
    end
end
