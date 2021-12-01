% auROC calcium analysis
% ZZ 05/19/21
% ROC and single unit classifier
% as implemented in Kingsbury...Hong (2020) Neuron

% LOAD INTO WORKSPACE:  
% 1) sig1 = signal matrix (sigfn, dff, or spkfn)[ref paper uses dff]
% NB: most load into workspace with name 'sig1' 
% 2) frlut = frame lookup table, generated by  'align_timestamp_frames' func
% 3) eventvec = behavior / event vector (as Nx1 vector)

% NB1: sig length MUST match eventmat length (see align data section)
% NB2: eventmat and sig MUST be in the same timeframe as each other (ie
% eventmat(1) is the same time as sig(1), eventmat(100) == sig(100), etc).
% (see align data section)

function [n_excited, n_suppressed, auc_n, percent_excited, percent_suppressed] = caROC(sig, eventmat, session_name)
%% align data
% use cutoff to trim data if needed (based on behavior vector)
% if want to use all, leave cutoff empty
% cutoff = [50313];
% 
% if isempty(cutoff)
%     cutoff = length(eventvec);
% end
% eventmat = eventvec(1:cutoff);
% 
% % take only the calcium frames aligned to the behavior
% sig = sig1(:,frlut{1:cutoff,2});

%% zscore data
zsig = zscore(sig, 0, 2);  % zscore data to normalize
nn = size(zsig,1);  % Number of Neurons
nf = size(zsig,2);  % Number of Frames

%% generate ROC using matlab func perfcurve
%only take 100 samples to prevent: 1) step functions in ROC curve; 2)
%different sized ROC vectors curves
roc = zeros(100,2,nn);
auc_n = zeros(1,nn);
x = [];
y = [];

for i_n = 1:nn
    [x,y,~,AUC] = perfcurve(eventmat,zsig(i_n,:),1);
    %x_samples = x(1:length(x)/100:end);
    %y_samples = y(1:length(y)/100:end);
    x_samples = x(round(linspace(1, length(x), 100)));
    y_samples = y(round(linspace(1, length(y), 100)));
    roc(:,:,i_n) = [x_samples,y_samples];
    auc_n(i_n) = AUC;
end

%% plot ROCs to take a look at each one. Comment out if no plot desired
%  for zz = 1:nn
%      plot(roc(:,1,zz), roc(:,2,zz));
%      pause;
%  end

%% generate null distribution of auROCs 
% circularly shuffle event timing and recalculating ROCs
% this takes a while (note the parfor loop)

perm = 1000;
auc_perm = zeros(nn,perm);
parfor i_perm = 1:perm
    i_start = randi([2,length(eventmat)],1);
    eventmat_shuf = vertcat(eventmat(i_start:end), eventmat(1:i_start-1));
    
    for i_n = 1:nn
      [~,~,~,AUC] = perfcurve(eventmat_shuf,zsig(i_n,:),1);
      auc_perm(i_n,i_perm) = AUC;
    end
end
% 

%% compute percentile of real auROCs
centile = zeros(nn,1);
for i_n = 1:nn
    nless = sum(auc_perm(i_n,:) < auc_n(i_n));
    nequal = sum(auc_perm(i_n,:) == auc_n(i_n));
    centile(i_n) = 100 * (nless + 0.5*nequal) / size(auc_perm,2);
end

n_suppressed = find(centile <= 2.5);
n_excited = find(centile >= 97.5);
percent_excited = 100*size(n_excited, 1)/i_n;
percent_suppressed = 100*size(n_suppressed, 1)/i_n;

%% plot sig ROCs to take a look at each one. 
% Comment out if no plot desired

mkdir ROC_Figures
cd('ROC_Figures')
mkdir(session_name)
cd(session_name)

figure;
for zz = 1:length(n_excited)
     plot(roc(:,1,n_excited(zz)), roc(:,2,n_excited(zz)));
     title(['excited cell ID #' num2str(n_excited(zz))]);
     xlabel('True Positive Rate')
     ylabel('False Positive Rate')
     savefig(['ROC_excited_cell_#' num2str(n_excited(zz))])
%     pause;
end
 
for zz = 1:length(n_suppressed)
     plot(roc(:,1,n_suppressed(zz)), roc(:,2,n_suppressed(zz)));
     title(['suppressed cell ID #' num2str(n_suppressed(zz))]);
     xlabel('True Positive Rate')
     ylabel('False Positive Rate')
     savefig(['ROC_suppressed_cell_#' num2str(n_suppressed(zz))])
%     pause;
end

close(gcf);
cd('../..')

disp('Analysis Complete')
disp(['Excited: ' num2str(100*size(n_excited, 1)/i_n) '%'])
disp(['Suppressed: ' num2str(100*size(n_suppressed, 1)/i_n) '%'])
%% visualize histogram of real auROC (red line) vs null distribution
% Comment out if desired
% nsig = length(n_suppressed) + length(n_excited);
% sigcells = [n_excited; n_suppressed];
% for zz = 1:nsig
%     histogram(auc_perm(sigcells(zz),:),50);
%     xline(auc_n(sigcells(zz)),'r');
%     title(['histogram of shuffled auROCs - cell ID #' num2str(sigcells(zz))]);
%     pause;
%     clf;
end