% This code is similar to "StimEnvelope_NetOutput_EEG_CrossCorr" but finds
% the correlation between stim envelope and all layers of the trained and
% random networks.
% 
% @ May 2020 - SH

clc; clear; close all;
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas';
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Sylvain'))
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
%% Variables %%
%%%%%%%%%%%%%%%
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
load('xcorr_env')
num_shfl = 100;
num_layers = 5;
num_neurons = 2048;
initName = 'AllStimuliforExp2WithAllEmbeddingsRandomNetwork000';
rnd1 = [6,20,6,10,23,22,11,1,16,23,23,15,9,22,12,23,1,14,18,5,9,5,9,11,14];
rnd2 = [14,7,7,7,4,24,24,21,19,5,10,5,1,8,18,9,14,11,8,13,20,20,15,19,17];
[Net_unrl_stim,Net_unrl_out,Net_rl_stim] = deal(zeros(num_neurons, mn, num_stim,num_layers));
[Net_unrl_stim_lags,Net_unrl_out_lags,Net_rl_stim_lags] = deal(zeros(mn, num_stim));
%% Main %%
%%%%%%%%%%
for shfl = 1:num_shfl
    fileName = [initName(1:end-length(num2str(shfl))) num2str(shfl)];
    a = load([MatlabRoot '/Data/random_networks/' fileName]);
    
    myEmbeddings = cell(num_layers,num_stim);
    myEmbeddings(1,:) = a.myEmbeddingsLayer1;
    myEmbeddings(2,:) = a.myEmbeddingsLayer2;
    myEmbeddings(3,:) = a.myEmbeddingsLayer3;
    myEmbeddings(4,:) = a.myEmbeddingsRNN;
    myEmbeddings(5,:) = a.myEmbeddingsLayer5;
    clear a
    %% Cross Corr with all related and unrelated stimuli
    % xcorr with the main stim will be on the diagonal
    [NetCrossCorr_mat,Netlags] = deal(cell(num_stim,num_stim));
    temp = [];
    for stim1 = 1:num_stim % Main stim
        %%%%%%%%%% xcross with the output of each layer of the net %%%%%%%%%%%%
        ind = find(rnd2 == stim1);
        if isempty(ind) % only run through rnd1 and 2
            k = [stim1,rnd1(stim1)];
        else
            k = [stim1,rnd1(stim1),ind];
        end
        for lay = 1:num_layers
            for nron = 1:num_neurons
                x = myEmbeddings{lay,stim1}(:,nron)';
                for stim2 = k % All other stim
                    y = Env{5,stim2};
                    [NetCrossCorr_mat{stim1,stim2}(nron,:,lay),Netlags{stim1,stim2}] = xcorr(zscore(x),zscore(y));
                    % find the minimum size of the matrices in CrossCorr_mat
                    temp = [temp,length(Netlags{stim1,stim2})];
                end
            end
        end
        disp(['**** Stim ' num2str(stim1) ' done *****'])
    end
    mn = min(temp);
    %% Extract related and unrelated combinations
    % rnd = randi(num_stim,1,num_stim); % ran and saved once
    for lay = 1:num_layers
        for stim = 1:num_stim % Main stim
            Net_unrl_stim(:,:,stim,lay) = Net_unrl_stim(:,:,stim,lay)+NetCrossCorr_mat{stim,rnd1(stim)}(:,1:mn,lay); % the xcorr of an output of the network with a random unrelated stimulus
            Net_unrl_out(:,:,stim,lay)  = Net_unrl_out(:,:,stim,lay)+NetCrossCorr_mat{rnd2(stim),stim}(:,1:mn,lay); % the xcorr of an stimulus with a random unrelated output of the network
            Net_rl_stim(:,:,stim,lay) = Net_rl_stim(:,:,stim,lay)+NetCrossCorr_mat{stim,stim}(:,1:mn,lay);  % the xcorr of each stim with the related network output
            % corresponding lags
            Net_unrl_stim_lags(:,stim) = Netlags{stim,rnd1(stim)}(:,1:mn);
            Net_unrl_out_lags(:,stim)  = Netlags{rnd2(stim),stim}(:,1:mn);
            Net_rl_stim_lags(:,stim) = Netlags{stim,stim}(:,1:mn);
        end
    end
    disp('************************************')
    disp(['**** shuffle ' num2str(shfl) ' is done *****'])
    disp('************************************')
end
Net_unrl_stim = Net_unrl_stim./num_shfl;
Net_unrl_out = Net_unrl_out./num_shfl;
Net_rl_stim = Net_rl_stim./num_shfl;
%% save
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
save('zscored_xcorr_env_RandomNet','Net_unrl_stim','Net_unrl_out','Net_rl_stim',...
    'Net_unrl_stim_lags','Net_unrl_out_lags','Net_rl_stim_lags');
