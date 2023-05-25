%% refineFeatures

function refineFeatures(varargin)

% Collect Features struct from inputs
Features = varargin{1};

%% Remove features not useful to PMA analysis
to_remove = {'shockToneVector', 'freezingShockVector', 'movingShockVector', 'freezingMovingVector', 'freezingPlatentVector', 'freezingPlatextVector','movingPlatentVector', 'movingPlatextVector', 'platentPlatextVector', 'platentPlatformVector', 'platextPlatformVector','BLshocktoneVector', 'BLfreezingshockVector', 'BLmovingshockVector', 'BLfreezingmovingVector', 'BLfreezingplatentVector', 'BLfreezingplatextVector','BLmovingplatentVector', 'BLmovingplatextVector', 'BLplatentplatextVector', 'BLplatentplatformVector', 'BLplatextplatformVector','ELshocktoneVector', 'ELfreezingshockVector', 'ELmovingshockVector', 'ELfreezingmovingVector', 'ELfreezingplatentVector', 'ELfreezingplatextVector','ELmovingplatentVector', 'ELmovingplatextVector', 'ELplatentplatextVector', 'ELplatentplatformVector', 'ELplatextplatformVector','MLshocktoneVector', 'MLfreezingshockVector', 'MLmovingshockVector', 'MLfreezingmovingVector', 'MLfreezingplatentVector', 'MLfreezingplatextVector','MLmovingplatentVector', 'MLmovingplatextVector', 'MLplatentplatextVector', 'MLplatentplatformVector', 'MLplatextplatformVector','LLshocktoneVector', 'LLfreezingshockVector', 'LLmovingshockVector', 'LLfreezingmovingVector', 'LLfreezingplatentVector', 'LLfreezingplatextVector','LLmovingplatentVector', 'LLmovingplatextVector', 'LLplatentplatextVector', 'LLplatentplatformVector', 'LLplatextplatformVector','ERshocktoneVector', 'ERfreezingshockVector', 'ERmovingshockVector', 'ERfreezingmovingVector', 'ERfreezingplatentVector', 'ERfreezingplatextVector','ERmovingplatentVector', 'ERmovingplatextVector', 'ERplatentplatextVector', 'ERplatentplatformVector', 'ERplatextplatformVector','MRshocktoneVector', 'MRfreezingshockVector', 'MRmovingshockVector', 'MRfreezingmovingVector', 'MRfreezingplatentVector', 'MRfreezingplatextVector','MRmovingplatentVector', 'MRmovingplatextVector', 'MRplatentplatextVector', 'MRplatentplatformVector', 'MRplatextplatformVector','LRshocktoneVector', 'LRfreezingshockVector', 'LRmovingshockVector', 'LRfreezingmovingVector', 'LRfreezingplatentVector', 'LRfreezingplatextVector','LRmovingplatentVector', 'LRmovingplatextVector', 'LRplatentplatextVector', 'LRplatentplatformVector', 'LRplatextplatformVector'}';

for i = 1:length(to_remove)
    try
        Features = rmfield(Features, to_remove(i));
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


% Make a list of contents of Features struct
features = fieldnames(Features);

N_features = size(features, 1);

% Remove any features with match for strings in inputs > 1
if nargin > 1
    rmv_terms = {};
    for i = 2:nargin
        rmv_terms = [rmv_terms, varargin{i}];
    end

    to_remove = zeros(size(features));

    for i = 1:size(rmv_terms, 2)
        this_term = rmv_terms{i};
        mtch_inds = contains(features, this_term);
        to_remove(mtch_inds) = 1;
    end

    % Remove IDed features
    Features = rmfield(Features, features(logical(to_remove)));

else
    % Display list of features and allow user to remove them
    %[to_remove, tf] = listdlg('PromptString', 'Select features to remove from analysis',...
    %        'ListString', features,...
    %        'SelectionMode', 'multiple')
    
   % Features = rmfield(Features, features(logical(to_remove)));
end

%% Save refined Features as 'rFeatures.mat'
new_N_features = size(fieldnames(Features), 1);

save('rFeatures.mat', 'Features')
end




