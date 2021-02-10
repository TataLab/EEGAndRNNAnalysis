% This code finds the envelope of stimulus, then calculates the half-wave
% rectification of the first derivative of the envelope. 
% These steps were done in "StimEnvelope_NetOutput_CrossCorr" and saved
% already.
% This code finds the cross correlation with the desired signal, which can
% be EEG or the network output. Here we look at both.
% Shweta's data were used as the input to the network
% 
% Q: acoustic envelope was downsampled to have the same Fs as the network
% output, before cross correlation. Should I downsample the EEG to have the
% same Fs as this or we can keep the eeg sampling rate intact, and reduce
% the sampling rate of acoustic envelope to that for the xcorr between
% these two? Both Fs return similar results, just a bit smoother with the higher Fs.
%
% Note: Both Dillon and Shweta discarded the first 1000ms of data to avoid 
% looking at the onset ERP transient response from the low level auditory 
% system (which is an order of magnitude bigger amplitude than the phase 
% tracking response). There is the same onset response at the beginning of 
% each sentence and it doesn?t depend on which sentence, so the xcorr with 
% random sentences will probably have that same onset response.  
% The solution is to flatten the first 500 ms of both the envelope and the
% EEG and then ramp on the second 500. (I did the same)
% 
% @ May 2020 - SH
% Modified @ Aug 2020 - SH (zscored before the xcorr)

clc; clear; close all;
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas';
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Sylvain'))
load([MatlabRoot '/Data/AllStimuliforExp2WithEmbeddings'])
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
%% Variables %%
%%%%%%%%%%%%%%%
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
load('xcorr_env')
num_subj = 16;      % Native speakers only
% I chose fronto-central channels based on the sensor layout of GSN 200, not sure 
% if it's the net that Shweta used! ref: GSN_sensorLayout_pg128.pdf
ch = [25,20,11,4,124,21,12,5,119,13,6,113]; %(ch can be a vector of channels)
num_chnl = length(ch);
eeg_fs = 250;
eeg_baseline = 0.7;  % 0.7 sec at the beginning of eeg signal is the baseline before the trigger
%% Flattening the firs 500 ms and ramp up the second 500 ms.
%{
for stim = 1:num_stim % All other stim
    nPoints = floor(500*1e-3*sig_fs(stim));
    onRamp = linspace(0, 1, nPoints);
    
    y = Env{5,stim};
    % Flatten the begining of the signal
    y(1:nPoints) = 0;
    % A 500 ms onset ramp
    y(nPoints+1:2*nPoints) = y(nPoints+1:2*nPoints) .* onRamp';
    % Normalization (to have a summation of 1)
    y = y./sum(y);
    Env{6,stim} = y; clear y
end
%}
%% Cross Corr with all related and unrelated stimuli
% xcorr with the main stim will be on the diagonal
[NetCrossCorr_mat,Netlags,EEGCrossCorr_mat,EEGlags] = deal(cell(num_stim,num_stim));
for stim1 = 1:num_stim % Main stim
    %%%%%%%%%% xcross with the output of RNN layer of the net %%%%%%%%%%%%
    % To flatten the firs 500 ms and ramp up the second 500 ms.
    nPoints = floor(500*1e-3*sig_fs(stim1)); 
    % A 500 ms onset ramp
    onRamp = linspace(0, 1, nPoints);
    
    for nron = 1:num_neurons
        x = myEmbeddings{stim1}(:,nron)';
        %{
        % Flatten the begining of the signal
        x(1:nPoints) = 0;
        % A 500 ms onset ramp
        x(nPoints+1:2*nPoints) = x(nPoints+1:2*nPoints) .* onRamp;
        % Normalization (to have a summation of 1)
        x = x./sum(x);
        %}
        for stim2 = 1:num_stim % All other stim
            y = Env{5,stim2};
            [NetCrossCorr_mat{stim1,stim2}(nron,:),Netlags{stim1,stim2}] = xcorr(zscore(x),zscore(y));
        end
    end
    %%%%%%%%%% xcross with EEG %%%%%%%%%%%%%%%
    cte = 0;
    for subj = [1,3:num_subj]
        cte = cte+1;
        load(['/Volumes/EEGlab_SH/Saeedeh/ShwetasData/SortedEEGdat/eeg_' num2str(subj)],'EEGdat')
        % Order of trials: 1st stim was repeated 4 times, then 2nd stim
        % for 4 times, and so on to the 25th stim. -> 100 trials in total
        mEEGdat = mean(EEGdat(ch,:,4*(stim1-1)+1:4*stim1),3);  % Average across the repetitions
        mmEEGdat = mean(mEEGdat,1);  % Average across the selected channels
        % Downsample EEG signal to the same fs of the stim_env in cross-corr
        [p,q] = rat(sig_fs(stim1)/eeg_fs);
        x = resample(mmEEGdat,p,q);  
        % Visulization
        % t = (0:length(mmEEGdat)-1)./eeg_fs;
        % figure; plot(t,mmEEGdat,'.-k');hold on;
        % plot(linspace(0,t(end),length(x)),x,'.-r');
        
        EEGlags_shift = sig_fs(stim)*eeg_baseline; % number of datapoints for the baseline
        %{
        % Flatten the begining of the signal(after triger)
        x(EEGlags_shift+1:EEGlags_shift+nPoints) = 0;
        % A 500 ms onset ramp
        x(EEGlags_shift+nPoints+1:EEGlags_shift+2*nPoints) = x(EEGlags_shift+nPoints+1:EEGlags_shift+2*nPoints) .* onRamp;
        % Normalization (to have a summation of 1)
        x = x./sum(x);
        %}
        for stim2 = 1:num_stim  % All other stim
            y = Env{5,stim2};
            [EEGCrossCorr_mat{stim1,stim2}(cte,:),EEGlags{stim1,stim2}] = xcorr(zscore(x),zscore(y));
            EEGlags{stim1,stim2} = EEGlags{stim1,stim2}-EEGlags_shift;
        end
        clear EEGdat mEEGdat
    end
    disp(['**** Stim ' num2str(stim1) ' done *****'])
end

%% find the minimum size of the matrices in CrossCorr_mat
temp1 = [];temp2 = [];
for stim1 = 1:num_stim
    for stim2 = 1:num_stim
        temp1 = [temp1,length(Netlags{stim1,stim2})];
        temp2 = [temp2,length(EEGlags{stim1,stim2})];
    end
end
mn1 = min(temp1);mn2 = min(temp2);
%% Extract related and unrelated combinations
% rnd = randi(num_stim,1,num_stim); % ran and saved once
rnd1 = [6,20,6,10,23,22,11,1,16,23,23,15,9,22,12,23,1,14,18,5,9,5,9,11,14];
rnd2 = [14,7,7,7,4,24,24,21,19,5,10,5,1,8,18,9,14,11,8,13,20,20,15,19,17];
[Net_unrl_stim,Net_unrl_out,Net_rl_stim] = deal(zeros(num_neurons, mn1, num_stim));
[EEG_unrl_stim,EEG_unrl_out,EEG_rl_stim] = deal(zeros(num_subj-1, mn2, num_stim));
[Net_unrl_stim_lags,Net_unrl_out_lags,Net_rl_stim_lags] = deal(zeros(mn1, num_stim));
[EEG_unrl_stim_lags,EEG_unrl_out_lags,EEG_rl_stim_lags] = deal(zeros(mn2, num_stim));
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Note that the eeg signal includes 0.7sec baseline from the pre-stimulus.
% Se we have to shift EEGlags if we wanna have the point zero to state the 
% trigger, as indicated below.
% 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

for stim = 1:num_stim % Main stim
    Net_unrl_stim(:,:,stim) = NetCrossCorr_mat{stim,rnd1(stim)}(:,1:mn1); % the xcorr of an output of the network with a random unrelated stimulus
    Net_unrl_out(:,:,stim)  = NetCrossCorr_mat{rnd2(stim),stim}(:,1:mn1); % the xcorr of an stimulus with a random unrelated output of the network
    EEG_unrl_stim(:,:,stim) = EEGCrossCorr_mat{stim,rnd1(stim)}(:,1:mn2); % the xcorr of an EEG with a random unrelated stimulus
    EEG_unrl_out(:,:,stim)  = EEGCrossCorr_mat{rnd2(stim),stim}(:,1:mn2); % the xcorr of an stimulus with a random unrelated EEG

    Net_rl_stim(:,:,stim) = NetCrossCorr_mat{stim,stim}(:,1:mn1);  % the xcorr of each stim with the related network output
    EEG_rl_stim(:,:,stim) = EEGCrossCorr_mat{stim,stim}(:,1:mn2);  % the xcorr of each stim with the related EEG signal
    
    % corresponding lags
    Net_unrl_stim_lags(:,stim) = Netlags{stim,rnd1(stim)}(:,1:mn1);
    Net_unrl_out_lags(:,stim)  = Netlags{rnd2(stim),stim}(:,1:mn1);
    EEG_unrl_stim_lags(:,stim) = EEGlags{stim,rnd1(stim)}(:,1:mn2);
    EEG_unrl_out_lags(:,stim)  = EEGlags{rnd2(stim),stim}(:,1:mn2);
    
    Net_rl_stim_lags(:,stim) = Netlags{stim,stim}(:,1:mn1);
    EEG_rl_stim_lags(:,stim) = EEGlags{stim,stim}(:,1:mn2);
end
%% save
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
save('zscored_xcorr_env_Net_EEG','Net_unrl_stim','Net_unrl_out','Net_rl_stim',...
    'EEG_unrl_stim','EEG_unrl_out','EEG_rl_stim'...
    ,'Net_unrl_stim_lags','Net_unrl_out_lags','Net_rl_stim_lags'...
    ,'EEG_unrl_stim_lags','EEG_unrl_out_lags','EEG_rl_stim_lags');
