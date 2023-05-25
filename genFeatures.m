function Features = genFeatures(Cues, caBehavior)

% Initialize Features structure
Features = struct();

% Make a list of cue vectors to combine
cue_labels = fieldnames(Cues);

for i = 1:size(cue_labels, 1)
    cue_vectors{i,1} = Cues.(cue_labels{i}).Vector;
end

% Make a list of behavior vectors to combine
beh_labels = fieldnames(caBehavior);
beh_vectors = cell(size(beh_labels,1), 1);

% Collect vector data from caBehavior 
for i = 1:size(beh_labels, 1)
    beh_vectors{i} = caBehavior.(beh_labels{i}).Vector;
end

% Override beh vectors if cue vectors exist
c = 0;

for i = 1:length(cue_labels)
    match_test = strcmpi(cue_labels(i), beh_labels);
    
    % If match, replace behav vector version
    if sum(match_test) == 1
        beh_vectors(match_test) = cue_vectors(i);
    % Otherwise, add cue vector to base list    
    else
        c = c + 1;
        add_cue_vectors{c, 1} = cue_vectors{i};
        add_cue_labels{c, 1} = cue_labels{i};
    end
end

% Make vectors for base cue/behavior sets
base_vectors = [beh_vectors; add_cue_vectors];
base_labels = [beh_labels; add_cue_labels];

% Prep vector names for base vectors
for i = 1:size(base_vectors, 1)
    base_labels{i} = newVecName(base_labels{i});
end

% Record base vectors in Features struct
for i = 1:size(base_vectors, 1)
    Features.(base_labels{i}) = base_vectors{i};
end

%% Combine all base_vectors and save into Features

for i = 1:(size(base_vectors, 1) - 1)
    for ii = (i + 1):size(base_vectors, 1)
        new_vec = double(base_vectors{i} & base_vectors{ii});
        new_label = newVecName(base_labels{i}, base_labels{ii});
        Features.(new_label) = new_vec;
    end
end

% Remove redundant vectors
feat_list = fieldnames(Features);
to_remove = zeros(size(feat_list));

for i = 1:length(feat_list)
    if count(feat_list{i}, 'plat', 'IgnoreCase', true) > 1 || count(feat_list{i}, 'tone', 'IgnoreCase', true) > 1
        to_remove(i) = 1;
    end
    
    if sum(Features.(feat_list{i})) == 0
        to_remove(i) = 1;
    end
end

Features = rmfield(Features, feat_list(logical(to_remove)));

end