%% caAnalyze_runROC


function caAnalyze_runROC(Features, signal, sig_label)

%% Run ROC Analysis on all Relevant Vectors

ROC_Log = table();

% Generate a list of Vectors from caBehavior to test on ROC
features = fieldnames(Features);

% Organize vectors to cycle through & cooresponding output folder names

for ii = 1:size(features, 1)
    eventmat = Features.(features{ii})';
    session_name = [sig_label '_' features{ii}];
    roc_run_error = false;

    try
        % Loop through ROC analysis script, saving data in appropriate folders
        [n_excited, n_suppressed, auc_n, percent_excited, percent_suppressed]...
        = caROC(signal, eventmat, session_name);
    
        % Store run data in a temp log
        Signal = {sig_label};
        Vector = features(ii);
        Excited = {n_excited};
        Prcnt_E = [percent_excited];
        Suppressed = {n_suppressed};
        Prcnt_S = [percent_suppressed];
        Excited_AUC = {auc_n(n_excited)'};
        Suppressed_AUC = {auc_n(n_suppressed)'};
        ROC_Log = vertcat(ROC_Log, table(Signal, Vector, Excited, Prcnt_E, Suppressed, Prcnt_S, Excited_AUC, Suppressed_AUC));
   
    catch
        disp(['Error running ROC on ' features{ii}])
        disp(['Error dir: ' pwd])
        roc_run_error = true;
    end

    if ~roc_run_error
        save('ROC_Log.mat', 'ROC_Log')
    end
end
end




