% This code is similar to "StimEnvelope_NetOutput_EEG_CrossCorr" but finds
% the correlation between stim envelope and all layers of the trained and
% random networks.
% 
% @ May 2020 - SH

clc;clear; close all;
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas';
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Sylvain'))
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
%% Variables %%
%%%%%%%%%%%%%%%
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
load('xcorr_env')
a = load([MatlabRoot '/Data/AllStimuliforExp2WithAllEmbeddings']);
num_layers = 5;
myEmbeddings = cell(num_layers,num_stim);
myEmbeddings(1,:) = a.myEmbeddingsLayer1;
myEmbeddings(2,:) = a.myEmbeddingsLayer2;
myEmbeddings(3,:) = a.myEmbeddingsLayer3;
myEmbeddings(4,:) = a.myEmbeddingsRNN;
myEmbeddings(5,:) = a.myEmbeddingsLayer5;
clear a
temp = zeros(1,5);
for lay = 1:5
    temp(lay) = size(myEmbeddings{lay,1},2);
end
if length(unique(temp)) == 1
    num_neurons = unique(temp);
else
    disp('Different layers have different number of neurons')
end
%% Cross Corr with all related and unrelated stimuli
% xcorr with the main stim will be on the diagonal
[NetCrossCorr_mat,Netlags] = deal(cell(num_stim,num_stim));

for stim1 = 1:num_stim % Main stim
    %%%%%%%%%% xcross with the output of each layer of the net %%%%%%%%%%%%
    for lay = 1:num_layers
        for nron = 1:num_neurons
            x = myEmbeddings{lay,stim1}(:,nron)';
            for stim2 = 1:num_stim % All other stim
                y = Env{5,stim2};
                [NetCrossCorr_mat{stim1,stim2}(nron,:,lay),Netlags{stim1,stim2}] = xcorr(zscore(x),zscore(y));
            end
        end
    end
    disp(['**** Stim ' num2str(stim1) ' done *****'])
end

%% find the minimum size of the matrices in CrossCorr_mat
temp = [];
for stim1 = 1:num_stim
    for stim2 = 1:num_stim
        temp = [temp,length(Netlags{stim1,stim2})];
    end
end
mn = min(temp);
%% Extract related and unrelated combinations
% rnd = randi(num_stim,1,num_stim); % ran and saved once
rnd1 = [6,20,6,10,23,22,11,1,16,23,23,15,9,22,12,23,1,14,18,5,9,5,9,11,14];
rnd2 = [14,7,7,7,4,24,24,21,19,5,10,5,1,8,18,9,14,11,8,13,20,20,15,19,17];
[Net_unrl_stim,Net_unrl_out,Net_rl_stim] = deal(zeros(num_neurons, mn, num_stim,num_layers));
[Net_unrl_stim_lags,Net_unrl_out_lags,Net_rl_stim_lags] = deal(zeros(mn, num_stim));
for lay = 1:num_layers
    for stim = 1:num_stim % Main stim
        Net_unrl_stim(:,:,stim,lay) = NetCrossCorr_mat{stim,rnd1(stim)}(:,1:mn,lay); % the xcorr of an output of the network with a random unrelated stimulus
        Net_unrl_out(:,:,stim,lay)  = NetCrossCorr_mat{rnd2(stim),stim}(:,1:mn,lay); % the xcorr of an stimulus with a random unrelated output of the network
        Net_rl_stim(:,:,stim,lay) = NetCrossCorr_mat{stim,stim}(:,1:mn,lay);  % the xcorr of each stim with the related network output
        % corresponding lags
        Net_unrl_stim_lags(:,stim) = Netlags{stim,rnd1(stim)}(:,1:mn);
        Net_unrl_out_lags(:,stim)  = Netlags{rnd2(stim),stim}(:,1:mn);
        Net_rl_stim_lags(:,stim) = Netlags{stim,stim}(:,1:mn);
    end
end
%% save
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
save('zscored_xcorr_env_TrainedNet','Net_unrl_stim','Net_unrl_out','Net_rl_stim',...
    'Net_unrl_stim_lags','Net_unrl_out_lags','Net_rl_stim_lags');
