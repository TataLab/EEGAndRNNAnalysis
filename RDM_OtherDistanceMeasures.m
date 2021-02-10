% This code is similar to RDMs_bothEEGandModel
% but uses other patternDistanceMeasure than 'correlation'
% 
% 
% @ June 2020 - SH

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
% Distance measure; correlation, euclidean, and mahalanobis
% % [RDMs_EEG_corr, RDMs_EEG_euclidean, RDMs_EEG_mahal] = deal(zeros(num_stim,num_stim,num_subj));
temp = struct2cell(responsePatterns_EEG.FrontoCentralChnls); cte = 0;
for sub = [1,3:16]
    cte = cte+1;
    [temp1,temp2] = deal(zeros(num_stim,num_stim,4));
    for ii = 1:4
        temp1(:,:,ii) = rsa.rdm.squareRDMs(pdist(temp{cte}(:,:,ii)','correlation'));
        temp2(:,:,ii) = rsa.rdm.squareRDMs(pdist(temp{cte}(:,:,ii)','euclidean'));
    end
    RDMs_EEG_corr(cte).RDM = mean(temp1,3); % average over repetitions
    RDMs_EEG_corr(cte).name = ['Subj' num2str(sub)];
    RDMs_EEG_corr(cte).color = [0,0,0];
    RDMs_EEG_euclidean(cte).RDM = mean(temp2,3); % average over repetitions
    RDMs_EEG_euclidean(cte).name = ['Subj' num2str(sub)];
    RDMs_EEG_euclidean(cte).color = [0,0,0];
end
RDMs_EEG_corr(cte+1).RDM = mean(reshape([RDMs_EEG_corr.RDM],num_stim,num_stim,[]),3);   % average over subjects
RDMs_EEG_corr(cte+1).name = 'Average over Subjs';
RDMs_EEG_corr(cte+1).color = [0,0,0];
RDMs_EEG_euclidean(cte+1).RDM = mean(reshape([RDMs_EEG_euclidean.RDM],num_stim,num_stim,[]),3);  % average over subjects
RDMs_EEG_euclidean(cte+1).name = 'Average over Subjs';
RDMs_EEG_euclidean(cte+1).color = [0,0,0];

%%%%%%%%%%%%%% Network %%%%%%%%%%%%%%%%%
% Distance measure; correlation, euclidean, and mahalanobis
% % [RDMs_Net_corr, RDMs_Net_euclidean, RDMs_Net_mahal] = deal(zeros(num_stim,num_stim,num_layers));
temp = {responsePatterns_Net_1.Layer1.noSubject, responsePatterns_Net_2.Layer2.noSubject,...
    responsePatterns_Net_3.Layer3.noSubject, responsePatterns_Net_RNN.LayerRNN.noSubject, ...
    responsePatterns_Net_5.Layer5.noSubject, responsePatterns_Net_6.Layer6.noSubject};
for lay = 1:num_layers
    RDMs_Net_corr(lay).RDM = rsa.rdm.squareRDMs(pdist(temp{lay}','correlation'));
    RDMs_Net_corr(lay).name = ['Layer' LayerNames(lay)];
    RDMs_Net_corr(lay).color = [0,0,0];
    RDMs_Net_euclidean(lay).RDM = rsa.rdm.squareRDMs(pdist(temp{lay}','euclidean'));
    RDMs_Net_euclidean(lay).name = ['Layer' LayerNames(lay)];
    RDMs_Net_euclidean(lay).color = [0,0,0];
end
RDMs_Net_corr(num_layers+1).RDM = mean(reshape([RDMs_Net_corr.RDM],num_stim,num_stim,[]),3);  % average over layers
RDMs_Net_corr(num_layers+1).name = 'Average over Layers';
RDMs_Net_corr(num_layers+1).color = [0,0,0];
RDMs_Net_euclidean(num_layers+1).RDM = mean(reshape([RDMs_Net_euclidean.RDM],num_stim,num_stim,[]),3); % average over layers
RDMs_Net_euclidean(num_layers+1).name = 'Average over Layers';
RDMs_Net_euclidean(num_layers+1).color = [0,0,0];
%% save
cd([MatlabRoot 'Result/RSA/CompareDistanceMeasures'])
save([FileNames{Net} '_corr_and_euclidean_RDMs'],'RDMs_Net_corr','RDMs_Net_euclidean')
save('EEG_corr_and_euclidean_RDMs','RDMs_EEG_corr','RDMs_EEG_euclidean')
%% First-order analysis %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display the RDMs and save them
cd([MatlabRoot 'Result/RSA/CompareDistanceMeasures'])
rsa.fig.showRDMs(RDMs_EEG_corr,1);      
save_plot(gcf,'RDMs_EEG_corr');
rsa.fig.showRDMs(RDMs_EEG_euclidean,2); 
save_plot(gcf,'RDMs_EEG_euclidean');
rsa.fig.showRDMs(RDMs_Net_corr,3);
save_plot(gcf,[FileNames{Net} '_RDMs_corr']);
rsa.fig.showRDMs(RDMs_Net_euclidean,4);
save_plot(gcf,[FileNames{Net} '_RDMs_euclidean']);
% rsa.fig.handleCurrentFigure([userOptions.rootPath,filesep,'simulatedSubjAndAverage'],userOptions);

% Display MDS plots for the condition sets for both streams of data
[blankConditionLabels{1:num_stim}] = deal(' ');
cd([MatlabRoot 'Result/RSA/CompareDistanceMeasures'])
userOptions_EEG.analysisName = 'EEG_corr';
rsa.MDSConditions(RDMs_EEG_corr(end), userOptions_EEG, struct('titleString', ...
    'MDS of conditions for EEG(corr)', 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 5));
save_plot(gcf,'MDSConditions_EEG_corr')
userOptions_EEG.analysisName = 'EEG_euclidean';
rsa.MDSConditions(RDMs_EEG_euclidean(end), userOptions_EEG, struct('titleString', ...
    'MDS of conditions for EEG(euclidean)', 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 6));
save_plot(gcf,'MDSConditions_EEG_euclidean')
userOptions_Net.analysisName = [FileNames{Net} '_corr'];
rsa.MDSConditions(RDMs_Net_corr(end), userOptions_Net, struct('titleString', ...
    'MDS of conditions for Net(corr)', 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 7));
save_plot(gcf,['MDSConditions_' FileNames{Net} '_corr'])
userOptions_Net.analysisName = 'Net_euclidean';
rsa.MDSConditions(RDMs_Net_euclidean(end), userOptions_Net, struct('titleString', ...
    'MDS of conditions for Net(euclidean)', 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 8));
save_plot(gcf,['MDSConditions_' FileNames{Net} '_euclidean'])
close all
%% Second-order analysis %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[cnct_RDM_corr,cnct_RDM_euclidean] = deal(cell(1,num_layers+1));
for lay = 1:num_layers
    cnct_RDM_corr{lay} = RDMs_Net_corr(lay);
    cnct_RDM_euclidean{lay} = RDMs_Net_euclidean(lay);
end
cnct_RDM_corr{num_layers+1} = RDMs_EEG_corr(end);
cnct_RDM_euclidean{num_layers+1} = RDMs_EEG_euclidean(end);
% Display a second-order simmilarity matrix for the model and the pattern RDMs
cd([MatlabRoot 'Result/RSA/CompareDistanceMeasures'])
userOptions_common.analysisName = ['EEGand' FileNames{Net} '_corr'];
rsa.pairwiseCorrelateRDMs(cnct_RDM_corr, userOptions_common, struct('figureNumber', 1));
save_plot(gcf,[FileNames{Net} '_pairwiseCorr_RDM_corr'])
userOptions_common.analysisName = ['EEGand' FileNames{Net} '_euclidean'];
rsa.pairwiseCorrelateRDMs(cnct_RDM_euclidean, userOptions_common, struct('figureNumber', 2));
save_plot(gcf,[FileNames{Net} 'pairwiseCorr_RDM_euclidean'])
%************ corrMat is saved in RSA/Statistics *************

% Plot all RDMs on a MDS plot to visualise pairwise distances.
cd([MatlabRoot 'Result/RSA/CompareDistanceMeasures'])
rsa.MDSRDMs(cnct_RDM_corr, userOptions_common, struct('titleString', 'MDS of EEG and Net RDMs (corr)', 'figureNumber', 3));
save_plot(gcf,['MDS_and_Shepardplot_' FileNames{Net} '_corr'])
rsa.MDSRDMs(cnct_RDM_euclidean, userOptions_common, struct('titleString', 'MDS of EEG and Net RDMs (euclidean)', 'figureNumber', 4));
save_plot(gcf,['MDS_and_Shepardplot_' FileNames{Net} '_euclidean'])
close all

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