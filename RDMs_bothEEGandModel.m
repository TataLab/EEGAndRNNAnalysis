% This code is written based on 'rsatoolbox-develop' toolbox and 
% specifically this demo: 'DEMO2_RSA_ROI_sim'
% This code finds the RDM for the EEG signals.
% First: I ran ShwetasData.m for loading the EEG data in the variable 'ALLEEGdata', making beta files
% and save them.
% 
% 
% @ May 2020 - SH

%% Initialisation %%
%%%%%%%%%%%%%%%%%%%%
clc; clear; close all
toolboxRoot = '/Volumes/EEGlab_SH/Saeedeh/rsatoolbox-develop/';
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(toolboxRoot));
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))

Net = input('Which Network you are ineterested in(1 for TrianedNet, 2 for RandomNet, 3 for PhonemeNet)?'); % 1 for TrianedNet, 2 for RandomNet, 3 for PhonemeNet
%% Variables %%
%%%%%%%%%%%%%%%
cd([MatlabRoot 'Data'])
FileNames = {'TrainedNet','RandomNet','PhonemeNet'};
load([FileNames{Net} 'Variables.mat'])

num_subj = 16;      % EEG var: Native speakers only
num_rep = 4;        % EEG var: number of repetitions (which will be assumed as session later in the RDM analysis)
num_trials = 100;   % EEG var
trial_length = 8.5; % EEG var: unit(sec)

% Common var
patternDistanceMeasure = 'correlation'; % For calculating RDMs

%% Load auserOptions and betaCorrespondence %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([MatlabRoot 'Result/RSA/userOptions/' FileNames{Net} '_userOptions.mat'])

%load betaCorrespondence
load('/Volumes/EEGlab_SH/Saeedeh/ShwetasData/betaCorrespondence.mat');
betaCorrespondence_EEG = betaCorrespondence;
load([MatlabRoot 'Result/RSA/Network_Betas/betaCorrespondence.mat']);
betaCorrespondence_Net = betaCorrespondence;
clear betaCorrespondence
%% Data Preparation %%
%%%%%%%%%%%%%%%%%%%%%%
cd(toolboxRoot);
% We work with 'fmri' toolbox, but uses eeg data. The steps are similar in both.
% Load in the EEG data (Frontal Channels only)
fullBrainVols = rsa.fmri.fMRIDataPreparation(betaCorrespondence_EEG, userOptions_EEG);
fullNetVols1 = rsa.fmri.fMRIDataPreparation(betaCorrespondence_Net, userOptions_Net_1);
fullNetVols2 = rsa.fmri.fMRIDataPreparation(betaCorrespondence_Net, userOptions_Net_2);
fullNetVols3 = rsa.fmri.fMRIDataPreparation(betaCorrespondence_Net, userOptions_Net_3);
fullNetVolsRNN = rsa.fmri.fMRIDataPreparation(betaCorrespondence_Net, userOptions_Net_RNN);
fullNetVols5 = rsa.fmri.fMRIDataPreparation(betaCorrespondence_Net, userOptions_Net_5);
fullNetVols6 = rsa.fmri.fMRIDataPreparation(betaCorrespondence_Net, userOptions_Net_6);

% Name the RoIs for data
RoIName = 'FrontoCentralChnls';  %RoI: Region of Interest
responsePatterns_EEG.(RoIName) = fullBrainVols;

responsePatterns_Net_1.Layer1 = fullNetVols1;
responsePatterns_Net_2.Layer2 = fullNetVols2;
responsePatterns_Net_3.Layer3 = fullNetVols3;
responsePatterns_Net_RNN.LayerRNN = fullNetVolsRNN;
responsePatterns_Net_5.Layer5 = fullNetVols5;
responsePatterns_Net_6.Layer6 = fullNetVols6;
%% RDMs %%
%%%%%%%%%%

%%%%%%%%%%%%%% EEG %%%%%%%%%%%%%%%%%
% Construct RDMs: One RDM for each subject 
% (1 session per subject for now, we later can add the repetitions)
% and one for the average across subjects.
RDMs_EEG = rsa.constructRDMs(responsePatterns_EEG, betaCorrespondence_EEG, userOptions_EEG);
% Next line is necessary only if we have more than one session per subject
RDMs_EEG = rsa.rdm.averageRDMs_subjectSession(RDMs_EEG, 'session');  
averageRDMs_EEG = rsa.rdm.averageRDMs_subjectSession(RDMs_EEG, 'subject'); % average over the subjects

%%%%%%%%%%%%%% Network %%%%%%%%%%%%%%%%%
RDM_Net_1 = rsa.constructRDMs(responsePatterns_Net_1, betaCorrespondence_Net, userOptions_Net_1);
temp = strfind(RDM_Net_1.name,'|'); RDM_Net_1.name = RDM_Net_1.name(1:temp(1)-2);
RDM_Net_2 = rsa.constructRDMs(responsePatterns_Net_2, betaCorrespondence_Net, userOptions_Net_2);
temp = strfind(RDM_Net_2.name,'|'); RDM_Net_2.name = RDM_Net_2.name(1:temp(1)-2);
RDM_Net_3 = rsa.constructRDMs(responsePatterns_Net_3, betaCorrespondence_Net, userOptions_Net_3);
temp = strfind(RDM_Net_3.name,'|'); RDM_Net_3.name = RDM_Net_3.name(1:temp(1)-2);
RDM_Net_RNN = rsa.constructRDMs(responsePatterns_Net_RNN, betaCorrespondence_Net, userOptions_Net_RNN);
temp = strfind(RDM_Net_RNN.name,'|'); RDM_Net_RNN.name = RDM_Net_RNN.name(1:temp(1)-2);
RDM_Net_5 = rsa.constructRDMs(responsePatterns_Net_5, betaCorrespondence_Net, userOptions_Net_5);
temp = strfind(RDM_Net_5.name,'|'); RDM_Net_5.name = RDM_Net_5.name(1:temp(1)-2);
RDM_Net_6 = rsa.constructRDMs(responsePatterns_Net_6, betaCorrespondence_Net, userOptions_Net_6);
temp = strfind(RDM_Net_6.name,'|'); RDM_Net_6.name = RDM_Net_6.name(1:temp(1)-2);
% Putting all network RDMs in one big structure
RDM_Net(1) = RDM_Net_1;
RDM_Net(2) = RDM_Net_2;
RDM_Net(3) = RDM_Net_3;
RDM_Net(4) = RDM_Net_RNN;
RDM_Net(5) = RDM_Net_5;
RDM_Net(6) = RDM_Net_6;

% Next line is necessary only if we have more than one session per subject
% RDM_Net = rsa.rdm.averageRDMs_subjectSession(RDMs_Network, 'session');  
% averageRDMs_Net = rsa.rdm.averageRDMs_subjectSession(RDM_Network, ...
% 'subject'); % average over the subjects

%% First-order analysis %%
%%%%%%%%%%%%%%%%%%%%%%%%%%
cd([MatlabRoot 'Result/RSA'])
% Display the RDMs for each subject as well as their average
rsa.figureRDMs(rsa.rdm.concatenateRDMs(RDMs_EEG, averageRDMs_EEG), userOptions_EEG,struct('fileName', 'EEGRDM', 'figureNumber', 1))
save_plot(gcf,'EEG_RDMs/Figures/EEG_RDMs')
rsa.figureRDMs(RDM_Net, userOptions_Net, struct('fileName', 'modelRDM', 'figureNumber', 2))
save_plot(gcf,['Network_RDMs/' FileNames{Net} '/Figures/RDMs_Net'])
rsa.figureRDMs(RDM_Net_1, userOptions_Net_1, struct('fileName', 'modelRDM', 'figureNumber', 3))
save_plot(gcf,['Network_RDMs/' FileNames{Net} '/Figures/RDMs_NetLayer1'])
rsa.figureRDMs(RDM_Net_2, userOptions_Net_2, struct('fileName', 'modelRDM', 'figureNumber', 4))
save_plot(gcf,['Network_RDMs/' FileNames{Net} '/Figures/RDMs_NetLayer2'])
rsa.figureRDMs(RDM_Net_3, userOptions_Net_3, struct('fileName', 'modelRDM', 'figureNumber', 5))
save_plot(gcf,['Network_RDMs/' FileNames{Net} '/Figures/RDMs_NetLayer3'])
rsa.figureRDMs(RDM_Net_RNN, userOptions_Net_RNN, struct('fileName', 'modelRDM', 'figureNumber', 8))
save_plot(gcf,['Network_RDMs/' FileNames{Net} '/Figures/RDMs_NetLayerRNN'])
rsa.figureRDMs(RDM_Net_5, userOptions_Net_5, struct('fileName', 'modelRDM', 'figureNumber', 6))
save_plot(gcf,['Network_RDMs/' FileNames{Net} '/Figures/RDMs_NetLayer5'])
rsa.figureRDMs(RDM_Net_6, userOptions_Net_6, struct('fileName', 'modelRDM', 'figureNumber', 7))
save_plot(gcf,['Network_RDMs/' FileNames{Net} '/Figures/RDMs_NetLayer6'])
close all

% Determine dendrograms for the clustering of the conditions
[blankConditionLabels{1:num_stim}] = deal(' ');
rsa.dendrogramConditions(averageRDMs_EEG, userOptions_EEG, struct('titleString', ...
    'Dendrogram of conditions', 'useAlternativeConditionLabels', true, 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 9));
save_plot(gcf,'EEG_RDMs/EEG_Dendrogram_FrontoCentralChnls')
% rsa.dendrogramConditions(averageRDMs_Net, userOptions_Net, struct('titleString', 'Dendrogram of conditions', 'useAlternativeConditionLabels', true, 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 3));

% Display MDS plots for the condition sets for both streams of data
rsa.MDSConditions(averageRDMs_EEG, userOptions_EEG, struct('titleString', ...
    'MDS of conditions for EEG', 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 10));
% % % % % % % Error in convex hull: which makes sense
%% Second-order analysis %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
cnct_RDM = {RDM_Net_1,RDM_Net_2,RDM_Net_3,RDM_Net_RNN,RDM_Net_5,RDM_Net_6,averageRDMs_EEG};
% Display a second-order simmilarity matrix for the model and the pattern RDMs
rsa.pairwiseCorrelateRDMs(cnct_RDM, userOptions_common, struct('figureNumber', 11));
cd([MatlabRoot 'Result/RSA/EEGandNetwork_RDM_Comparison'])
save_plot(gcf,['EEGand' FileNames{Net} '_PairwiseComparison'])
%************ corrMat is saved in RSA/Statistics *************

% Plot all RDMs on a MDS plot to visualise pairwise distances.
rsa.MDSRDMs({RDM_Net,averageRDMs_EEG}, userOptions_common, struct('titleString', 'MDS of EEG and Net RDMs', 'figureNumber', 12));
save_plot(gcf,['EEGand' FileNames{Net} '_RDMsonMDSplot'])
% models = cell(1,num_layers+1);
% for ii = 1:6
%     models{ii} = RDM_Net(ii);
% end
% models{7} = averageRDMs_EEG;

%% statistical inference %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test the relatedness and compare the candidate RDMs

% userOptions = userOptions_noisy;
% userOptions.RDMcorrelationType='Kendall_taua';
% userOptions.RDMrelatednessTest = 'subjectRFXsignedRank';
% userOptions.RDMrelatednessThreshold = 0.05;
% userOptions.figureIndex = [10 11];
% userOptions.RDMrelatednessMultipleTesting = 'FDR';
% userOptions.candRDMdifferencesTest = 'subjectRFXsignedRank';
% userOptions.candRDMdifferencesThreshold = 0.05;
% userOptions.candRDMdifferencesMultipleTesting = 'none';
% stats_p_r=rsa.compareRefRDM2candRDMs(RDMs_noisy, models, userOptions);