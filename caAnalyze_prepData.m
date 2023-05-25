%% caAnalyze_prepData

function caAnalyze_prepData(analysis_dirs, ca_downsample, csp_ID, us_ID, ca_fileID)

for n = 1:size(analysis_dirs, 1)
    
    current_data_dir = analysis_dirs{n};
    cd(current_data_dir)
    
    % Register files in current_data_dir
    behDepot_search = dir('*_analyzed*');
    ca_search = dir(ca_fileID);
    cue_search = dir('*cue*.csv');
    ts_search = dir('*timeStamps*.csv');
    frlu_search = dir('*frlu*.mat');
    % Cues_search = dir('*Cues*.mat');
    
    skip = 0;
   
    % If BehDepot output and calcium data are successfully detected
    if size(behDepot_search, 1) == 1 && size(ca_search, 1) == 1
        if size(frlu_search, 1) == 1
            gen_frlu = 0;
            frlu_file = frlu_search.name;
        else
            if size(ts_search, 1) == 2
                gen_frlu = 1;
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
        disp('BehDepot output and/or calcium traces not detected for this session')
        disp('Skipping folder') 
    
    % Otherwise, run main analysis script
    else
        % Set required files aquired through search
        behDepot_dir = behDepot_search.name;
        ca_file = ca_search.name;

        % Parse through cue files and ID csp and/or us files (should be ca
        % aligned)
        if size(cue_search, 1) > 0
            csp_search = dir('*csp*.csv');
            us_search = dir('*us*.csv');
            
            if size(csp_search, 1) == 1
                csp_file = csp_search.name;
            end

            if size(us_search, 1) == 1
                us_file = us_search.name;
            end
        end
        
        clearvars behDepot_search ca_search cue_search csp_search us_search frlu_search ts_search
%% Load Calcium Data
        % Load signals from output file
        signals = load(ca_file, 'sigfn', 'dff', 'spkfn');
        total_ca_frames = size(signals.sigfn, 2);
        
%% Load Cue Script

%% OLD VERSION: Load 'cueframes' var from .mat file
%         try
%             load(cue_file, 'cueframes')
%             cueframes;
%             clearvars cueframes
%         catch
%             % Generate cueframes if not already present
%             datetime = input('Enter video timestamp', 's')
%             calcCueFrames(cue_file, 30, datetime);
%             load(cue_file, 'cueframes')
%             cueframes;
%             clearvars cueframes
%         end

%% NEW VERSION: Load csp and/or us CSV files
        if exist('csp_file')
            cues.csp = load(csp_file);
        end
        if exist('us_file')
            cues.us = load(us_file);
        end
        
        clearvars csp_file us_file
%% Make general cue vectors (currently, tones (csp) and shocks (us))
        Cues = genCueStruct(cues, total_ca_frames, ca_downsample, csp_ID, us_ID);

%% Load BehaviorDEPOT output data
        cd(behDepot_dir)
        load('Behavior.mat')
        load('Metrics.mat')
        cd(current_data_dir)
        
%% Load and/or generate frlu
        % Prompt generation of lookup table, if not found
        if gen_frlu == 1
            f_tbl = prepFrluData(ms_ts_file, beh_ts_file);
            [frlu, frlu_cols] = createFrlu(f_tbl, ca_downsample);

            % Save lookup table at same path as v4 timestamps
            save('frlu.mat', 'frlu', 'frlu_cols')
        else
            load(frlu_file);
        end
        
%% Generate caBehavior Struct to Hold Aligned Behavior Data
    caBehavior = beh2Mini(Behavior, Metrics, frlu, total_ca_frames);
        
%% Make Vectors for Combined Cues / Behaviors
        
    % Combine all cue & behavior vectors and save in Features
    Features = genFeatures(Cues, caBehavior);
    
%% Segment tone/shock cues into learning periods (for v4PMA settings)
        
    % Collect labels for behavior session (learning / retrieval)
    Cues = getSessionLabels(Cues, total_ca_frames);
    
    % Make vectors in Features for each session period
    Features = applySession(Cues, Features);

    % Save session data to log struct
    save('Features.mat', 'Features')
    
    % Loop to next session in analysis_dirs
    end
end
end




