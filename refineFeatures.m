%% refineFeatures

function refineFeatures(varargin)

% Collect Features struct from inputs
Features = varargin{1};

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
    [to_remove, tf] = listdlg('PromptString', 'Select features to remove from analysis',...
            'ListString', features,...
            'SelectionMode', 'multiple')
    
    Features = rmfield(Features, features(logical(to_remove)));
end

%% Save refined Features as 'rFeatures.mat'
new_N_features = size(fieldnames(Features), 1);

if new_N_features ~= N_features
    save('rFeatures.mat', 'Features')
end
end




