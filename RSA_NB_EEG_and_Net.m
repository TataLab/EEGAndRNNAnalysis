% This code compares the RDM for EEG filtered in some narrower bands of
% interest and the Network RDMs of layers.
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
BW = 2; % narrwo-band filter for 2Hz BW
cte = 1; fltName = cell(1,10);
fltName{1} = 'LPF2Hz';
for ii = 2:2:18
    cte = cte+1;
    fltName{cte} = ['BPF' num2str(ii) 'to' num2str(ii+BW)];
end
%% Load RDMs %%
%%%%%%%%%%%%%%%
cd([MatlabRoot 'Result/RSA/RDM_narrowBandEEG'])
load('RDMs_NB_EEG','RDMs_EEG_corr','RDMs_EEG_euclidean')

cd([MatlabRoot 'Result/RSA/CompareDistanceMeasures'])
load([FileNames{Net} '_corr_and_euclidean_RDMs'],'RDMs_Net_corr','RDMs_Net_euclidean')
%% Prepare RDMs %% 
%%%%%%%%%%%%%%%%%%
% ***** Ran and saved once ******
%{
[RDMs_EEG_corr,RDMs_EEG_euclidean] = deal(cell(1,10));
for flt = 1:10
    cte = 0; 
    for sub = [1,3:16]
        cte = cte+1;
        RDMs_EEG_corr{flt}(cte).RDM = subjectRDMs_corr{flt}(:,:,cte); % average over repetitions
        RDMs_EEG_corr{flt}(cte).name = ['Subj' num2str(sub) ' | ' fltName{flt}];
        RDMs_EEG_corr{flt}(cte).color = [0,0,0];
        RDMs_EEG_euclidean{flt}(cte).RDM = subjectRDMs_euclidean{flt}(:,:,cte); % average over repetitions
        RDMs_EEG_euclidean{flt}(cte).name = ['Subj' num2str(sub) ' | ' fltName{flt}];
        RDMs_EEG_euclidean{flt}(cte).color = [0,0,0];
    end
    RDMs_EEG_corr{flt}(cte+1).RDM = mean(reshape([RDMs_EEG_corr{flt}.RDM],num_stim,num_stim,[]),3);   % average over subjects
    RDMs_EEG_corr{flt}(cte+1).name = ['Average over Subjs | ' fltName{flt}];
    RDMs_EEG_corr{flt}(cte+1).color = [0,0,0];
    RDMs_EEG_euclidean{flt}(cte+1).RDM = mean(reshape([RDMs_EEG_euclidean{flt}.RDM],num_stim,num_stim,[]),3);  % average over subjects
    RDMs_EEG_euclidean{flt}(cte+1).name = ['Average over Subjs | ' fltName{flt}];
    RDMs_EEG_euclidean{flt}(cte+1).color = [0,0,0];
end
%% save
cd([MatlabRoot 'Result/RSA/RDM_narrowBandEEG'])
load('RDMs_NB_EEG','RDMs_EEG_corr','RDMs_EEG_euclidean')
%}
%% Second-order analysis %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load auserOptions and betaCorrespondence
load([MatlabRoot 'Result/RSA/userOptions/' FileNames{Net} '_userOptions.mat'])

[cnct_RDM_corr,cnct_RDM_euclidean] = deal(cell(1,num_layers+1));
for lay = 1:num_layers
    cnct_RDM_corr{lay} = RDMs_Net_corr(lay);
    cnct_RDM_euclidean{lay} = RDMs_Net_euclidean(lay);
end
for flt = 1:10
    cnct_RDM_corr{num_layers+1} = RDMs_EEG_corr{flt}(end);
    cnct_RDM_euclidean{num_layers+1} = RDMs_EEG_euclidean{flt}(end);
    % Display a second-order simmilarity matrix for the model and the pattern RDMs
    cd([MatlabRoot 'Result/RSA/RDM_narrowBandEEG/' FileNames{Net}])
    userOptions_common.analysisName = [fltName{flt} '_EEG&' FileNames{Net} '_corr'];
    rsa.pairwiseCorrelateRDMs(cnct_RDM_corr, userOptions_common, struct('figureNumber', 1));
    save_plot(gcf,[fltName{flt} 'pairwiseCorr_RDM_corr'])
    userOptions_common.analysisName = [fltName{flt} '_EEG&' FileNames{Net} '_euclidean'];
    rsa.pairwiseCorrelateRDMs(cnct_RDM_euclidean, userOptions_common, struct('figureNumber', 2));
    save_plot(gcf,[fltName{flt} 'pairwiseCorr_RDM_euclidean'])
    %************ corrMat is saved in RSA/Statistics *************
    
    % Plot all RDMs on a MDS plot to visualise pairwise distances.
    cd([MatlabRoot 'Result/RSA/RDM_narrowBandEEG/' FileNames{Net}])
    rsa.MDSRDMs(cnct_RDM_corr, userOptions_common, struct('titleString', ['MDS ' fltName{flt} ' EEG&' FileNames{Net} '(corr)'], 'figureNumber', 3));
    save_plot(gcf,[fltName{flt} 'MDS_and_Shepardplot_corr'])
    rsa.MDSRDMs(cnct_RDM_euclidean, userOptions_common, struct('titleString', ['MDS ' fltName{flt} ' EEG&' FileNames{Net} '(euclidean)'], 'figureNumber', 4));
    save_plot(gcf,[fltName{flt} 'MDS_and_Shepardplot_euclidean'])
    close all
end