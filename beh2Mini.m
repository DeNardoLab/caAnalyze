% beh2Mini: post-BehaviorDEPOT Script for FRLU Generation and Miniscope-Aligned Prep

function caBehavior = beh2Mini(Behavior, Behavior_Filter, Metrics, frlu, total_ca_frames)
% Create a copy of data (for adjustment)
caBehavior = struct();

% Use lookup table to convert annotations in tempBehavior
behavs = fieldnames(Behavior);

% Find total frames with temporal downsample adjustment
% [ca_file, ca_path] = uigetfile('Select calcium file to match length to');
% load([ca_path ca_file], 'dff')

num_frames = total_ca_frames;

for i = 1:size(behavs, 1)
    % Pull out OG bouts from each behavior
    bouts = Behavior.(behavs{i}).Bouts;
    
    % Scan through all bouts and convert 
    for ii = 1:size(bouts, 1)
        strt = bouts(ii, 1);
        stp = bouts(ii, 2);
        
        % Find best matching frame
        [~, strt_test] = min(abs(frlu(:,1) - strt));
        [~, stp_test] = min(abs(frlu(:,1) - stp));
        
        % Convert from behCam to Miniscope
        bouts(ii, 1) = frlu(strt_test, 2);
        bouts(ii, 2) = frlu(stp_test, 2);
    end
    
    caBehavior.(behavs{i}) = genBehStruct(bouts(:,1), bouts(:,2), num_frames);
    
end

% Convert platform data from Behavior_Filter, if applicable
if exist('Behavior_Filter', 'var')
    try
        platformVector = Behavior_Filter.Spatial.Platform.inROIvector;
        [p_start, p_stop] = findStartStop(platformVector');
        
        for ii = 1:size(p_start, 1)
            strt = p_start(ii);
            stp = p_stop(ii);

            % Find best matching frame
            [~, strt_test] = min(abs(frlu(:,1) - strt));
            [~, stp_test] = min(abs(frlu(:,1) - stp));

            % Convert from behCam to Miniscope
            p_start(ii) = frlu(strt_test, 2);
            p_stop(ii) = frlu(stp_test, 2);
        end
        
        caBehavior.Platform = genBehStruct(p_start, p_stop, num_frames);
    end
end

% Save caBehavior struct
save('caBehavior.mat', 'caBehavior')

end