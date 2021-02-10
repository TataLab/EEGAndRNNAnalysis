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
clc;%clear;
toolboxRoot = '/Volumes/EEGlab_SH/Saeedeh/rsatoolbox-develop/';
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(toolboxRoot));
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
cd([MatlabRoot 'Result/RSA/EEG_RDMs'])
cd(toolboxRoot);
%% Variables
num_subj = 16;      % Native speakers only
num_stim = 25;
num_rep = 4;        % number of repetitions (which will be assumed as session later in the RDM analysis)
trial_length = 8.5; % unit:sec

cte = 0; subjectNames = cell(1,15);
for subj = [1,3:16]
    cte = cte+1;
    subjectNames{1,cte} = ['subject' num2str(subj)];
end
conditionLabels = cell(1,num_stim);
for stim = 1:num_stim
    conditionLabels{1,stim} = ['stim' num2str(stim)];
end

%% prepare userOptions
% Generate a userOptions structure and then change the parameters based of our ineterest.
userOptions_common = projectOptions_demo();

% it says that run the analysis everytime runing this code, even if you have ran and saved it before.
% Remember it will over-write the saved files. Put 'S' instead of 'R', if you don't wanna run it again. 
userOptions_common.forcePromptReply = 'R';
% Change the fields in the userOptions based on our data
userOptions = userOptions_common; 
userOptions.analysisName = 'EEG';
userOptions.rootPath = [MatlabRoot 'Result/RSA/EEG_RDMs'];  % The result path
userOptions.betaPath = '/Volumes/EEGlab_SH/Saeedeh/ShwetasData/Beta_SubjectFolders/[[subjectName]]/[[betaIdentifier]]';
userOptions.subjectNames = subjectNames;
userOptions.conditionLabels = conditionLabels;
userOptions.alternativeConditionLabels = cell(1,num_stim);
userOptions.conditionColours = linspecer(25);
userOptions.convexHulls = 1:25;
% colourScheme ?????????
userOptions.colourScheme = zeros(25,3);
userOptions.RDMname = 'EEG_RDM';

%load betaCorrespondence
load('/Volumes/EEGlab_SH/Saeedeh/ShwetasData/betaCorrespondence.mat')

%% Data Preparation
% We work with 'fmri' toolbox, but uses eeg data. The steps are similar in both.
% Load in the EEG data (Frontal Channels only)
fullBrainVols = rsa.fmri.fMRIDataPreparation(betaCorrespondence, userOptions);

% Name the RoIs for data
RoIName = 'FrontoCentralChnls';  %RoI: Region of Interest
responsePatterns.(RoIName) = fullBrainVols;
%% RDMs %%
%%%%%%%%%%

% Construct RDMs for the EEG data. One RDM for each subject 
% (1 session per subject for now, we later can add the repetitions)
% and one for the average across subjects.
RDMs_EEG = rsa.constructRDMs(responsePatterns, betaCorrespondence, userOptions);
% Next line is necessary only if we have more than one session per subject
RDMs_EEG = rsa.rdm.averageRDMs_subjectSession(RDMs_EEG, 'session');  
averageRDMs_EEG = rsa.rdm.averageRDMs_subjectSession(RDMs_EEG, 'subject'); % average over the subjects

%% First-order analysis: Display the RDMs for each subject as well as their average
rsa.figureRDMs(rsa.rdm.concatenateRDMs(RDMs_EEG, averageRDMs_EEG), userOptions,struct('fileName', 'EEGRDM', 'figureNumber', 1))
% 
% Determine dendrograms for the clustering of the conditions
rsa.dendrogramConditions(averageRDMs_EEG, userOptions, struct('titleString', 'Dendrogram of conditions', 'useAlternativeConditionLabels', true, 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 4));
% 
% Display MDS plots for the condition sets for both streams of data
rsa.MDSConditions(averageRDMs_true, userOptions_true, struct('titleString', 'MDS of conditions without simulated noise', 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 6));
rsa.MDSConditions(averageRDMs_noisy, userOptions_noisy, struct('titleString', 'MDS of conditions with simulated noise', 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 7));
% 