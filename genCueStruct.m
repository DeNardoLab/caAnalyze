%% genCueStruct

function Cues = genCueStruct(cues, total_ca_frames, ca_downsample, csp_ID, us_ID)

% OLD VERSION
% load(cue_file, 'cueframes', 'exp_ID');
% cues = fieldnames(cueframes);

cue_fields = fieldnames(cues);

for i = 1:length(cue_fields)
    if strcmpi(cue_fields(i), 'csp')
        
        Cues.(csp_ID) = round(cues.csp ./ ca_downsample);

        if strcmpi(csp_ID(end), 's') 
            Cues.([csp_ID(1:end-1), 'Vector']) = makeVector(Cues.(csp_ID), total_ca_frames);
        else
            Cues.([csp_ID, 'Vector']) = makeVector(Cues.(csp_ID), total_ca_frames);
        end
        
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
