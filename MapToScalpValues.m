% This code reads the file that contains spearman corrcoefs between all eeg
% electrodes and all network layers of trianed and random networks and
% prepare the values to be mapped to salp

clc;clear;close all
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

FileNames = {'TrainedNet','RandomNet'};  % Net var
load([MatlabRoot 'Result/RSA/Statistics/corrMats_AllEEGelecs_TrainedNet_RandNet100.mat'])
%% Ran and saved once
%{
%% TrainedNet %%
%%%%%%%%%%%%%%%%
EEG_TrainedNet = zeros(num_chnl+1,7); %last row is the reference, last column is the comparison with average of all layer RDMs
for ch = 1:num_chnl
    EEG_TrainedNet(ch,:) = corrMat_EEG_TrainedNet{ch,1}(23,1:7);
end
%% RandomNet %%
%%%%%%%%%%%%%%%
EEG_RandomNet = zeros(num_chnl+1,7);  %last row is the reference, last column is the comparison with average of all layer RDMs
for ch = 1:num_chnl
    for sh = 1:num_sh
        EEG_RandomNet(ch,:) = EEG_RandomNet(ch,:)+corrMat_EEG_RandNet{ch,sh}(23,1:7);
    end
    EEG_RandomNet(ch,:) = EEG_RandomNet(ch,:)./num_sh;
end
%% save %%
%%%%%%%%%%
cd([MatlabRoot 'Result/RSA/Statistics'])
save('corrMats_AllEEGelecs_TrainedNet_RandNet100.mat','EEG_RandomNet','EEG_TrainedNet','-append')
%}
%% 3D(or 2D) Map on Scalp %%
%%%%%%%%%%%%%%%%%%%%%
cd('/Users/saeedeh/Documents/MATLAB/eeglab2019_1')
eeglab
% File/load existing dataset: load a sample dataset (I loaded /Volumes/EEGlab_SH/Saeedeh/Saeedeh_Sylvain/Data/SPPE/Example of set file/P035/p035_ds.set)
% Here is another way to load a dataset:
% EEG = pop_loadset('p035_ds.set','/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Sylvain/Data/SPPE/Example of set file/P035');

% Then Edit/Channel locations and then in the popup window choose read locations
% Or EEG = pop_chanedit([]);  % ref: https://sccn.ucsd.edu/wiki/A03:_Importing_Channel_Locations
% in the popup window choose cancel and then choose read locations.

% Then load the file of electrode locations for GSN 200. here is the path:
% '/EEGlab_SH/Saeedeh/Saeedeh_Lukas/mapping the numbers to scalp/EGI_net_channel_locations_fromShweta.ced'
% (FYI: I took this file from Shweta)
% Now press ok.

EEG.pnts = 1;
EEG.times = 0;
EEG.chanlocs(129) = [];  % Since the data is already average referenced, I 
% should delete 129th electrode which was supposed to be the reference: Cz
EEG_TrainedNet(129,:) = [];
EEG_RandomNet(129,:) = [];
EEG.nbchan = 128;
EEG.ref = '';
layerTitle = {'Layer 1', 'Layer 2', 'Layer 3', 'RNN layer', 'Layer 5', 'Output layer', 'Average of all Layers'};
%% %%%%%%%%%%%%%%%%%%%% Trained Net %%%%%%%%%%%%%%%%%%%%%%%%%%%%
for lay = 1:5
    EEG.data = EEG_TrainedNet(:,lay);
    EEG.setname = [FileNames{1} ' ' layerTitle{lay}];
    % before running the next line, in pop_headplot, change 'ERP scalp maps
    % of dataset:' with 'Spearman Corcoef between EEG electrodes and ' in
    % line 258
    %%%%%%%%%%%%%%%%%% EEGOUT = pop_headplot(EEG, 1);
    %%%%%%%%%%%%%%%%%% Note %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The problem with pop_headplot or pop_topoplot is that they scale the
    % data points to fall in a certain range (-x to x). If you want to plot
    % the actual values, you should use
    % topoplot(EEG.data,EEG.chanlocs) instead.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if it doesn't co-register automatically, use these numbers in 'Talairach_model transformation matrix' box
    % 0.664455, -3.39403, -14.2521, -0.00241453, 0.015519, -1.55584, 11, 10.1455, 12
    % Then put 0 for the latency in the 'Making headplots for these latencies ...' box
    figure; topoplot(EEG.data,EEG.chanlocs);colorbar
    title({'Spearman Corcoef between EEG electrodes and' ,['layer ',num2str(lay) ' of trained network']})
    cd('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/Result/RSA/EEGandNetwork_RDM_Comparison/AllElecs')
    save_plot(gcf,['2D_ComparingEEG_and_TrainedNet_' layerTitle{lay}])
    cd('/Users/saeedeh/Documents/MATLAB/eeglab2019_1')
end
%% %%%%%%%%%%%%%%%%%%%% Random Net %%%%%%%%%%%%%%%%%%%%%%%%%%%%
for lay = 1:5
    EEG.data = EEG_RandomNet(:,lay);
    EEG.setname = [FileNames{2} ' ' layerTitle{lay}];
    % before running the next line, in pop_headplot, change 'ERP scalp maps
    % of dataset:' with 'Spearman Corcoef between EEG electrodes and ' in
    % line 258
    %%%%%%%%%%%%%%%%%% EEGOUT = pop_headplot(EEG, 1);
    %%%%%%%%%%%%%%%%%% Note %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The problem with pop_headplot or pop_topoplot is that they scale the
    % data points to fall in a certain range (-x to x). If you want to plot
    % the actual values, you should use
    % topoplot(EEG.data,EEG.chanlocs) instead.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if it doesn't co-register automatically, use these numbers in 'Talairach_model transformation matrix' box
    % 0.664455, -3.39403, -14.2521, -0.00241453, 0.015519, -1.55584, 11, 10.1455, 12
    % Then put 0 for the latency in the 'Making headplots for these latencies ...' box
    figure; topoplot(EEG.data,EEG.chanlocs);colorbar
    title({'Spearman Corcoef between EEG electrodes and',['layer ',num2str(lay) ' of random network']})
    cd('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/Result/RSA/EEGandNetwork_RDM_Comparison/AllElecs')
    save_plot(gcf,['2D_ComparingEEG_and_RandomNet_' layerTitle{lay}])
    cd('/Users/saeedeh/Documents/MATLAB/eeglab2019_1')
end