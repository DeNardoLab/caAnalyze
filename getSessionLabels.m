function Cues = getSessionLabels(Cues, total_frames)

%% Separate shocks by learning period
tone_number = 0;
shock_number = 0;

try
    tones = Cues.Tones.Bouts;
    tone_number = size(tones, 1);
end

try
    [~,session_id] = fileparts(pwd);
    if contains(session_id, 'T1')
        shock_number = 9;
    elseif contains(session_id, 'T2')
        shock_number = 12;
    end
end

%% Separate learning periods based on number of shocks
try
    % Learning sessions
    if tone_number == 12
        if shock_number == 9
            Cues.Session.type = 'T1';
            Cues.Session.BL = [1, tones(3,2)];
            Cues.Session.EL = [tones(3,2)+1, tones(6,2)];
            Cues.Session.ML = [tones(6,2)+1, tones(9,2)];
            Cues.Session.LL = [tones(9,2)+1, total_frames];
            Cues.Session.BLvector = makeVector(Cues.Session.BL, total_frames);
            Cues.Session.ELvector = makeVector(Cues.Session.EL, total_frames);
            Cues.Session.MLvector = makeVector(Cues.Session.ML, total_frames);
            Cues.Session.LLvector  = makeVector(Cues.Session.LL, total_frames);
        elseif shock_number == 12
            Cues.Session.type = 'T2';
            Cues.Session.BL = [1, tones(3,2)];
            Cues.Session.EL = [tones(3,2)+1, tones(6,2)];
            Cues.Session.ML = [tones(6,2)+1, tones(9,2)];
            Cues.Session.LL = [tones(9,2)+1, total_frames];
            Cues.Session.BLvector = makeVector(Cues.Session.BL, total_frames);
            Cues.Session.ELvector = makeVector(Cues.Session.EL, total_frames);
            Cues.Session.MLvector  = makeVector(Cues.Session.ML, total_frames);
            Cues.Session.LLvector  = makeVector(Cues.Session.LL, total_frames);
        elseif shock_number == 0
            Cues.Session.type = 'T_NS';
            Cues.Session.BL = [1, tones(3,2)];
            Cues.Session.EL = [tones(3,2)+1, tones(6,2)];
            Cues.Session.ML = [tones(6,2)+1, tones(9,2)];
            Cues.Session.LL = [tones(9,2)+1, total_frames];
            Cues.Session.BLvector = makeVector(Cues.Session.BL, total_frames);
            Cues.Session.ELvector = makeVector(Cues.Session.EL, total_frames);
            Cues.Session.MLvector = makeVector(Cues.Session.ML, total_frames);
            Cues.Session.LLvector = makeVector(Cues.Session.LL, total_frames);
        end

    % Retrieval sessions
    elseif tone_number == 9
        Cues.Session.ER = [1, tones(3,2)];
        Cues.Session.MR = [tones(3,2)+1, tones(6,2)];
        Cues.Session.LR = [tones(6,2)+1, total_frames];
        Cues.Session.ERvector = makeVector(Cues.Session.ER, total_frames);
        Cues.Session.MRvector = makeVector(Cues.Session.MR, total_frames);
        Cues.Session.LRvector  = makeVector(Cues.Session.LR, total_frames);
    end
    
    save('Cues', 'Cues')
end
end