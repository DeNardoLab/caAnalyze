%% genCueStruct

function Cues = genCueStruct(cues, total_ca_frames, ca_downsample, csp_ID, us_ID)

% OLD VERSION
% load(cue_file, 'cueframes', 'exp_ID');
% cues = fieldnames(cueframes);

cue_fields = fieldnames(cues);

ca_fps = 15;

for i = 1:length(cue_fields)
    if strcmpi(cue_fields(i), 'csp')
        
        struct_csp_ID = [upper(csp_ID(1)), csp_ID(2:end)];
        csp_ts = round(cues.csp ./ ca_downsample);
        Cues.(struct_csp_ID) = genBehStruct(csp_ts(:,1), csp_ts(:,2), total_ca_frames);
        csp_on = [csp_ts(:,1)-ca_fps, csp_ts(:,1)+ca_fps];
        csp_off = [csp_ts(:,2)-ca_fps, csp_ts(:,2)+ca_fps];
        
        Cues.ToneOn = genBehStruct(csp_on(:,1), csp_on(:,2), total_ca_frames);
        Cues.ToneOff = genBehStruct(csp_off(:,1), csp_off(:,2), total_ca_frames);
        
        iti_bouts = findStartStop(double(~Cues.(struct_csp_ID).Vector));
        Cues.ITI = genBehStruct(iti_bouts(:,1), iti_bouts(:,2), total_ca_frames);
        
        iti30_bouts = [iti_bouts(:,1), iti_bouts(:,1)+ca_fps * 30];
        Cues.ITI30 = genBehStruct(iti30_bouts(:,1), iti30_bouts(:,2), total_ca_frames);
        
    elseif strcmpi(cue_fields(i), 'us')
     
        Cues.(us_ID) = round(cues.us ./ ca_downsample);

        if strcmpi(us_ID(end), 's')
            Cues.([us_ID(1:end-1), 'Vector']) = makeVector(Cues.shocks, total_ca_frames);  
        else
            Cues.([us_ID, 'Vector']) = makeVector(Cues.shocks, total_ca_frames);
        end
    end
end

save('Cues', 'Cues')

end
