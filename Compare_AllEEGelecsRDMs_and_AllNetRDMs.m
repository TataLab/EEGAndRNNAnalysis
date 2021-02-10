m% This code loads the network RDMs of layers and EEG RDMs of all channels,
% then compares all network RDMs with all EEG RDMs 128 channels x 5 layers comparisons
% for trained network and for 128 channels x 6 layers x 100 shuffles for random networks
% 
% @ Aug 2020 - SH

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
num_subj = 16;      % EEG var: Native speakers only
num_rep = 4;        % EEG var: number of repetitions (which will be assumed as session later in the RDM analysis)
num_stim = 25;      % EEG var
num_trials = 100;   % EEG var
trial_length = 8.5; % EEG var: unit(sec)
num_chnl = 128;     % EEG var
num_sh = 100;
% load EEG RDMs
cd([MatlabRoot 'Result/RSA/EEG_RDMs_Of_AllElectrodes'])
load('EEG_euclidean_RDMs_AllElecs','RDMs_EEG_euclidean')

FileNames = {'TrainedNet','RandomNet','PhonemeNet'};  % Net var
%% Analysis for trained network
Net = 1; % for 'TrainedNet'
cd([MatlabRoot 'Data'])
load([FileNames{Net} 'Variables.mat'])
%%%%%%%%%%%% Load auserOptions %%%%%%%%%%%%
load([MatlabRoot 'Result/RSA/userOptions/' FileNames{Net} '_userOptions.mat'])
%%%%%%%%%%%% load Network RDMs %%%%%%%%%%%%%%
cd([MatlabRoot 'Result/RSA/CompareDistanceMeasures'])
load([FileNames{Net} '_corr_and_euclidean_RDMs'],'RDMs_Net_euclidean')
%%%%%%%%%%%% Second-order analysis %%%%%%%%%%%%%%
cnct_RDM_euclidean = cell(1,num_layers+num_subj+1);
for lay = 1:num_layers+1
    cnct_RDM_euclidean{lay} = RDMs_Net_euclidean(lay);
end
corrMat_EEG_TrainedNet = cell(num_chnl,1);
for ch = 1:num_chnl
    for subj = 1:num_subj
        cnct_RDM_euclidean{num_layers+subj+1} = RDMs_EEG_euclidean(ch,subj);
    end
    
    % Display a second-order simmilarity matrix for the model and the pattern RDMs
    cd([MatlabRoot 'Result/RSA/EEG_RDMs_Of_AllElectrodes/CompareRDMs_AllEEGElecs_NetLayers'])
    userOptions_common.analysisName = ['EEGch_',num2str(ch),'_',FileNames{Net} '_euclidean'];
    corrMat_EEG_TrainedNet{ch,1} = rsa.pairwiseCorrelateRDMs(cnct_RDM_euclidean, userOptions_common, struct('figureNumber', 1));
    save_plot(gcf,[FileNames{Net} 'pairwiseCorr_RDM_euclidean'])
    %************ corrMat is saved in RSA/Statistics *************
    % Plot all RDMs on a MDS plot to visualise pairwise distances.
    rsa.MDSRDMs(cnct_RDM_euclidean, userOptions_common, struct('titleString', 'MDS of EEG and Net RDMs (euclidean)', 'figureNumber', 2));
    save_plot(gcf,['MDS_and_Shepardplot_' FileNames{Net} '_euclidean'])
    close all
    disp(['***** TrainedNet Channel ' num2str(ch) ' done ******'])
end
%% Analysis for random networks
Net = 3; % for 'RandomNet'
cd([MatlabRoot 'Data'])
load([FileNames{Net} 'Variables.mat'])
%%%%%%%%%%%% Load auserOptions %%%%%%%%%%%%
load([MatlabRoot 'Result/RSA/userOptions/' FileNames{Net} '_userOptions.mat'])
%%%%%%%%%%%% load Network RDMs %%%%%%%%%%%%%%
cd([MatlabRoot 'Result/RSA/Network_RDMs/RandomNet'])
load('eucRDMs_RandomNet_100shf')
corrMat_EEG_RandNet = cell(num_chnl,num_sh);
for sh = 1:num_sh
    for lay = 1:num_layers
        RDMs_Net_euclidean(lay).RDM = eucRDMs_RandomNet_100shf{lay,sh};
    end
    RDMs_Net_euclidean(num_layers+1).RDM = mean(reshape([eucRDMs_RandomNet_100shf{:,sh}],25,25,[]),3);
    %%%%%%%%%%%% Second-order analysis %%%%%%%%%%%%%%
    cnct_RDM_euclidean = cell(1,num_layers+num_subj+1);
    for lay = 1:num_layers+1
        cnct_RDM_euclidean{lay} = RDMs_Net_euclidean(lay);
    end
    for ch = 1:num_chnl
        for subj = 1:num_subj
            cnct_RDM_euclidean{num_layers+subj+1} = RDMs_EEG_euclidean(ch,subj);
        end
        
        % Display a second-order simmilarity matrix for the model and the pattern RDMs
        cd([MatlabRoot 'Result/RSA/EEG_RDMs_Of_AllElectrodes/CompareRDMs_AllEEGElecs_NetLayers'])
        userOptions_common.analysisName = ['EEGch_',num2str(ch),'_',FileNames{Net}, '_sh', num2str(sh), '_euclidean'];
        corrMat_EEG_RandNet{ch,sh} = rsa.pairwiseCorrelateRDMs(cnct_RDM_euclidean, userOptions_common, struct('figureNumber', 1));
        save_plot(gcf,['EEGch_',num2str(ch),'_', FileNames{Net} 'pairwiseCorr_RDM_euclidean'])
        %************ corrMat is saved in RSA/Statistics *************
        % Plot all RDMs on a MDS plot to visualise pairwise distances.
        rsa.MDSRDMs(cnct_RDM_euclidean, userOptions_common, struct('titleString', 'MDS of EEG and Net RDMs (euclidean)', 'figureNumber', 2));
        save_plot(gcf,['MDS_and_Shepardplot_EEGch_',num2str(ch),'_', FileNames{Net} '_euclidean'])
        close all
        disp(['***** RandomNet Shuffle ' num2str(sh) ,' Channel' num2str(ch) ' done ******'])
    end
    
end
%% save 
cd([MatlabRoot 'Result/RSA/Statistics'])
save('corrMats_AllEEGelecs_TrainedNet_RandNet100','corrMat_EEG_RandNet','corrMat_EEG_TrainedNet')