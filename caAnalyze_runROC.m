%% caAnalyze_runROC


function caAnalyze_runROC(Features, signal)

%% Run ROC Analysis on all Relevant Vectors

ROC_Log = table();

% Generate a list of Vectors from caBehavior to test on ROC
features = fieldnames(Features, signal, sig_label);

% Organize vectors to cycle through & cooresponding output folder names

for ii = 1:size(features, 1)
    eventmat = Features.(features{ii})';
    session_name = [sig_label '_' features{ii}];

    % Loop through ROC analysis script, saving data in appropriate folders
    [n_excited, n_suppressed, auc_n, percent_excited, percent_suppressed]...
     = caROC(signal, eventmat, session_name);
    
    % Store run data in a temp log
    Signal = sig_labels(i);
    Vector = features(ii);
    Excited = [n_excited, percent_excited];
    Suppressed = [n_suppressed, percent_suppressed];
    ROC_Log = vertcat(ROC.Log, table(Signal, Vector, Excited, Suppressed));
    
end

save('ROC_Log.mat', 'ROC_Log')

end




