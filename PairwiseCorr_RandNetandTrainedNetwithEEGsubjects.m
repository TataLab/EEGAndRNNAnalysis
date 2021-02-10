% This code reads the RDMs saved for 
% Trained network, Random network (100shuffle), and EEG subjects and
% compares network RDMs with the EEG RDMs
%% Initialisation %%
%%%%%%%%%%%%%%%%%%%%
clc; clear; close all
toolboxRoot = '/Volumes/EEGlab_SH/Saeedeh/rsatoolbox-develop/';
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(toolboxRoot));
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
%% Variables %%
%%%%%%%%%%%%%%%
cd([MatlabRoot 'Data'])
load('RandomNetVariables')
num_shf = 100;

num_subj = 16;      % EEG var: Native speakers only
num_rep = 4;        % EEG var: number of repetitions (which will be assumed as session later in the RDM analysis)
num_trials = 100;   % EEG var
trial_length = 8.5; % EEG var: unit(sec)

load([MatlabRoot 'Result/RSA/userOptions/TrainedNet_userOptions.mat'],'userOptions_common')
userOptions_common.saveFiguresPDF = 0;
userOptions_common.displayFigures = 0;
%% Load RDMs %%
%%%%%%%%%%%%%%%

cd([MatlabRoot 'Result/RSA/Network_RDMs/RandomNet'])
load('eucRDMs_RandomNet_100shf')
cd([MatlabRoot 'Result/RSA/CompareDistanceMeasures'])
load('TrainedNet_corr_and_euclidean_RDMs','RDMs_Net_euclidean')
load('EEG_corr_and_euclidean_RDMs','RDMs_EEG_euclidean')

cte = 0;
for sh = 1:num_shf
    for lay = 1:num_layers
        cte = cte+1;
        RDMs_RNet100_euclidean(cte).RDM = eucRDMs_RandomNet_100shf{lay,sh};
        RDMs_RNet100_euclidean(cte).name = ['Layer ' LayerNames{lay} '|sh' num2str(sh)];
        RDMs_RNet100_euclidean(cte).color = [0,0,0];
    end
end

%% Main
corrMat_EEG_RandomNet = cell(num_subj-1,num_shf);
corrMat_EEG_TrainedNet = cell(num_subj-1,1);
for subj = 1:num_subj-1
    cte = 0;
    for sh = 1:num_shf
        cnct_EEG_RandomNet_RDMs = cell(1,num_layers+1);
        for lay = 1:num_layers
            cte = cte+1;
            cnct_EEG_RandomNet_RDMs{lay} = RDMs_RNet100_euclidean(cte);
        end
        cnct_EEG_RandomNet_RDMs{num_layers+1} = RDMs_EEG_euclidean(subj);
        userOptions_common.analysisName = ['EEG_subj' num2str(subj) '_RandNet' num2str(sh)];
        corrMat_EEG_RandomNet{subj,sh} = rsa.pairwiseCorrelateRDMs(cnct_EEG_RandomNet_RDMs,...
            userOptions_common,struct('figureNumber', 1));
        close all
    end
    cnct_EEG_TrainedNet_RDMs = cell(1,num_layers+1);
    for lay = 1:num_layers
        cnct_EEG_TrainedNet_RDMs{lay} = RDMs_Net_euclidean(lay);
    end
    cnct_EEG_TrainedNet_RDMs{num_layers+1} = RDMs_EEG_euclidean(subj);
    userOptions_common.analysisName = ['EEG_subj' num2str(subj) '_TranedNet'];
    corrMat_EEG_TrainedNet{subj,1} = rsa.pairwiseCorrelateRDMs(cnct_EEG_TrainedNet_RDMs,...
        userOptions_common,struct('figureNumber', 1));
    close all
    disp(['***** Subject ' num2str(subj) ' done ******'])
end
%% save
cd([MatlabRoot 'Result/RSA/Statistics'])
save('corrMats_EEGsubj_TrainedNet_RandNet100','corrMat_EEG_RandomNet','corrMat_EEG_TrainedNet')