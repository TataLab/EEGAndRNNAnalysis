% This code finds Euclidean RDMs of all EEG electrodes and saves them in a
% file. 
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

%% Load userOptions and betaCorrespondence %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load betaCorrespondence
%{
load('/Volumes/EEGlab_SH/Saeedeh/ShwetasData/betaCorrespondence.mat');
betaCorrespondence_EEG = allChbetaCorrespondence;
clear allChbetaCorrespondence
%}
%% Data Preparation %%
%%%%%%%%%%%%%%%%%%%%%%
fullBrainVols = cell(1,num_chnl);
for subj = [1,3:16]
    cd(['/Volumes/EEGlab_SH/Saeedeh/ShwetasData/Beta_SubjectFolders/subject' num2str(subj)])
    for stim = 1:25
        for rep = 1:4
            load(['allChBeta_stim', num2str(stim),'_rep', num2str(rep)])
            for ch = 1:num_chnl
                eval(['fullBrainVols{ch}.subject' num2str(subj),'(:,stim,rep) = betaImage(:,ch);']) 
            end
            clear betaImage
        end
    end
end
%% RDMs %%
%%%%%%%%%%
% Distance measure; euclidean
cd(toolboxRoot);
for ch = 1:num_chnl
    temp = struct2cell(fullBrainVols{ch}); cte = 0;
    for sub = [1,3:16]
        cte = cte+1;
        [temp1,temp2] = deal(zeros(num_stim,num_stim,4));
        for ii = 1:4
            temp2(:,:,ii) = rsa.rdm.squareRDMs(pdist(temp{cte}(:,:,ii)','euclidean'));
        end
        RDMs_EEG_euclidean(ch,cte).RDM = mean(temp2,3); % average over repetitions
        RDMs_EEG_euclidean(ch,cte).name = ['Subj' num2str(sub)];
        RDMs_EEG_euclidean(ch,cte).color = [0,0,0];
    end
    RDMs_EEG_euclidean(ch,cte+1).RDM = mean(reshape([RDMs_EEG_euclidean.RDM],num_stim,num_stim,[]),3);  % average over subjects
    RDMs_EEG_euclidean(ch,cte+1).name = 'Average over Subjs';
    RDMs_EEG_euclidean(ch,cte+1).color = [0,0,0];
end
%% save
cd([MatlabRoot 'Result/RSA/EEG_RDMs_Of_AllElectrodes'])
save('EEG_euclidean_RDMs_AllElecs','RDMs_EEG_euclidean')