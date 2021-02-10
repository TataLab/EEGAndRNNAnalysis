% This code is to locate where data is stored as well as the corresponding
% pre-processing scripts. This code reads te EEG data, sort the trials and
% save the Beta images and betaCorrespondence
% 
% 
% @ May 2020 - SH

clc;clear all;close all;
Root = '/Volumes/My Book/EEG_Data_Shweta/SPPE_Exp2/';
addpath(genpath(Root))
ScriptRoot = [Root, 'Data Analysis scripts/'];
eegDataRoot = [Root, 'SubjectEEGData/'];

num_subj = 16;      % Native speakers only
num_stim = 25;
num_trials = 100;
num_rep = 4;        % number of repetitions (which will be assumed as session later in the RDM analysis)
trial_length = 8.5; % unit:sec

% In the eegDataRoot, each folder corresponds to one subject and suffix 'N'
% indicates Native speakers.

% The file I probably need is 'Bandpass' filter dat 1-20Hz.
% Raw data were recorded at 500Hz sampling rate, then BP filtered between
% 1-20Hz and then downsampled at 250Hz.
% Finally stored in the 'EEGdata' variable at 
% '...-BandpassFiltered_1-20Hz_downsampled_250hz.mat'
% The corresponding script for data extraction is:
% [ScriptRoot, '/EEG Data Analysis/EEGEpochsExtraction_Bandpass1_20Hz.m']

%% Data fileNames:
fileNames = {...
'SPPE_e2_N_01 20161014 1700';...
''; ...
'SPPE_e2_N_03 20161017 1108';...
'SPPE_e2_N_04 20161017 1554';...
'SPPE_e2_N_05 20161018 1105';...
'SPPE_e2_N_06 20161018 1306';...
'SPPE_e2_N_07 20161114 1140';...
'SPPE_e2_N_08 20161115 0939';...
'SPPE_e2_N_09 20161116 0952';...
'SPPE_e2_N_10 20161116 1140';...
'SPPE_e2_N_11 20161121 0938';...
'SPPE_e2_N_12 20161122 0946';...
'SPPE_e2_N_13 20161122 1139';...
'SPPE_e2_N_14 20161128 1552';...
'SPPE_e2_N_15 20161202 1108';...
'SPPE_e2_N_16 20161202 1539'};

%% Read EEG data, and make Beta's for seperate subjects
sufx = '-BandpassFiltered_1-20Hz_downsampled_250hz.mat';
Beh_file_name = 'SPPE_e2_N_00.mat';

% I chose fronto-central channels based on the sensor layout of GSN 200, 
% it's the net that Shweta used! ref: GSN_sensorLayout_pg128.pdf
ch = [25,20,11,4,124,21,12,5,119,13,6,113]; %(ch can be a vector of channels)
num_chnl = length(ch);

for subj = [1,3:num_subj]
    d = num2str(subj);
    cd([eegDataRoot, d, '_N'])
    load([fileNames{subj},sufx],'EEGdata')
    % EEGdata is a 128 x 2125 x 100 matrix
    % channeln x datapoints x trials
    %%%%%%%% sort trials %%%%%%%
    Beh_file_name(end-3-length(d):end-4) = d;
    load([Root, 'SubjectBehavData/', Beh_file_name],'triggerCodes')
    cte = 1;
    presented_order = zeros(1,num_subj);
    for tr = 1:4:num_trials
        presented_order(1,cte) = str2double(triggerCodes(tr,1:2));
        cte = cte+1;
    end
    [B,I] = sort(presented_order,'ascend');
    EEGdat = zeros(size(EEGdata));
    for ii = 1:25
        EEGdat(:,:,4*(ii-1)+1:4*(ii-1)+4) = EEGdata(:,:,4*(I(ii)-1)+1:4*(I(ii)-1)+4); %sorted EEGdata
    end
    save(['/Volumes/EEGlab_SH/Saeedeh/ShwetasData/SortedEEGdat/eeg_' d],'EEGdat')
    % % Visualization for one example:
    % figure;plot(1:2125,squeeze(EEGdat(6,:,1:10)))
    % [f,~,s_amp,d_amp] = FrequencyDomain(250,EEGdat(6,:,1)-mean(EEGdat(6,:,1)),1);

    %%%%%%%%%%%% Make Beta's %%%%%%%%%%%%%%%%%%%%
    cd('/Volumes/EEGlab_SH/Saeedeh/ShwetasData/Beta_SubjectFolders')
    mkdir(['subject' num2str(subj)])
    cd(['subject' d])
    for rep = 1:num_rep   % ~session
        for stim = 1:num_stim  %~Condition
            % Order of trials: 1st stim was repeated 4 times, then 2nd stim
            % for 4 times, and so on to the 25th stim. -> 100 trials in total
            betaImage = EEGdat(ch,:,4*(stim-1)+rep)';  % 2125 x num_chnl
            save(['Beta_stim' num2str(stim) '_rep' num2str(rep)],'betaImage')
        end
    end
    clear EEGdat betaImage
end
%% Make betaCorrespondence
% betaCorrespondence store the name of the beta files
for rep = 1:num_rep
    for stim = 1:num_stim
        betaCorrespondence(rep,stim).identifier = ['Beta_stim' num2str(stim) '_rep' num2str(rep) '.mat'];
    end
end
cd('/Volumes/EEGlab_SH/Saeedeh/ShwetasData')
save('betaCorrespondence','betaCorrespondence')
