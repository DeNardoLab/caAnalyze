function Cues = genCueStruct(cue_file, totalCaFrames, downsample)

load(cue_file, 'cueframes', 'exp_ID');
cues = fieldnames(cueframes);

Cues.ID = exp_ID;

for i = 1:length(cues)
    if strcmp(cues(i), 'csp')
        
        Cues.tones = round(cueframes.(cues{i}) ./ downsample);
        Cues.toneVector = makeVector(Cues.tones, totalCaFrames);
        
    elseif strcmp(cues(i), 'us')
     
        Cues.shocks = round(cueframes.(cues{i}) ./ downsample);
        Cues.shockVector = makeVector(Cues.shocks, totalCaFrames);  
        
    end
end

save(['Cues_' exp_ID], 'Cues')

end
