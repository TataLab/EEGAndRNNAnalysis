% This code is written based on 'rsatoolbox-develop' toolbox and 
% specifically this demo: 'DEMO2_RSA_ROI_sim'
% This code finds the RDM for the output signals of the network.
% 
% 
% @ May 2020 - SH 
%% Initialisation %%
%%%%%%%%%%%%%%%%%%%%
clc; clear;
toolboxRoot = '/Volumes/EEGlab_SH/Saeedeh/rsatoolbox-develop/';
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(toolboxRoot));
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
cd(toolboxRoot);
%% Variables
num_neurons = 2048;
num_stim = 25;
num_trials = 100;
trial_length = 8.5; % unit:sec

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
userOptions.analysisName = 'Network_OutputLayer';
userOptions.rootPath = [MatlabRoot 'Result/RSA/Network_RDMs'];  % The result path
userOptions.betaPath = [MatlabRoot 'Result/RSA/Network_Betas/Net_OutLay_Betas/[[betaIdentifier]]'];
userOptions.subjectNames = {'Model'};
userOptions.conditionLabels = conditionLabels;
userOptions.alternativeConditionLabels = cell(1,num_stim);
userOptions.conditionColours = linspecer(25);
userOptions.convexHulls = 1:25;
% colourScheme ?????????
userOptions.colourScheme = zeros(25,3);
userOptions.RDMname = 'Network_RDM';

%load betaCorrespondence
load([MatlabRoot 'Result/RSA/Network_Betas/Net_OutLay_Betas/betaCorrespondence.mat'])

%% Data Preparation
% We work with 'fmri' toolbox, but uses Network data. The steps are similar in both.
% Load in the Network data.
fullNetworkVols = rsa.fmri.fMRIDataPreparation(betaCorrespondence, userOptions);

% Name the RoIs for data
RoIName = 'Output_Layer';  %RoI: Region of Interest
responsePatterns.(RoIName) = fullNetworkVols;
%% RDMs %%
%%%%%%%%%%

% Construct RDMs for the Network data. One RDM for each subject 
% (1 session per subject for now, we later can add the repetitions)
% and one for the average across subjects.
RDMs_Network = rsa.constructRDMs(responsePatterns, betaCorrespondence, userOptions);
% Next line is necessary only if we have more than one session per subject
% RDMs_Network = rsa.rdm.averageRDMs_subjectSession(RDMs_Network, 'session');  
% averageRDMs_Network = rsa.rdm.averageRDMs_subjectSession(RDMs_Network, ...
% 'subject'); % average over the subjects

%% First-order analysis: Display the RDMs for each model as well as their average
rsa.figureRDMs(RDMs_Network, userOptions, struct('fileName', 'modelRDM', 'figureNumber', 2))
% 
% Determine dendrograms for the clustering of the conditions 
[blankConditionLabels{1:size(RDMs_Network(1).RDM, 2)}] = deal(' ');
% 
% Display MDS plots for the condition sets for both streams of data
rsa.MDSConditions(averageRDMs_true, userOptions_true, struct('titleString', 'MDS of conditions without simulated noise', 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 6));
rsa.MDSConditions(averageRDMs_noisy, userOptions_noisy, struct('titleString', 'MDS of conditions with simulated noise', 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 7));
% 