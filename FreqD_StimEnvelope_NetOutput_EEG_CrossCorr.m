% This codes finds the frequency representation of the xcorr between
% stim-envelope and either network output or the EEG signal
% 
% 
% @ June 2020 - SH
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
num_stim = 25;
% I chose fronto-central channels based on the sensor layout of GSN 200, not sure 
% if it's the net that Shweta used! ref: GSN_sensorLayout_pg128.pdf
ch = [25,20,11,4,124,21,12,5,119,13,6,113]; %(ch can be a vector of channels)
num_chnl = length(ch);
eeg_fs = 250;
eeg_baseline = 0.7;  % 0.7 sec at the beginning of eeg signal is the baseline before the trigger

cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
load('xcorr_env_Net_EEG')
%% Plot Network: Average across a group of neurons
% [Netm_dat1,Netsem_dat1,Netm_dat2,Netsem_dat2,Netm_dat3,Netsem_dat3] = deal(zeros(num_stim,39));
close all
nfft = 32;
flag = 0;
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
    %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Netind = find(Net_rl_stim_lags(:,stim)>=-lim & Net_rl_stim_lags(:,stim)<=lim);
    dat = squeeze(Net_rl_stim(:,Netind,stim));
    % Choosing the 80% of nodes with higher maximum magnitudes in the selected window
    [mdat,I] = max(abs(dat),[],2);
    Mx = prctile(mdat,20);
    CNodes = I(mdat>Mx);
    % [Fdat_Net_rl_stim{stim},f_Net_rl_stim{stim}] = pwelch(dat(CNodes,:)',sig_fs(stim));
    % [Fdat_Net_rl_stim(:,:,stim),f_Net_rl_stim(:,stim)] = pyulear(dat(CNodes,:)',10,nfft,sig_fs(stim));
    [f_Net_rl_stim(stim,:),~,Fdat_Net_rl_stim(stim,:),~] = FrequencyDomain(sig_fs(stim),mean(dat(CNodes,:))-mean(mean(dat(CNodes,:))),flag);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(Net_unrl_stim) %%%%%%%%%%%%%%
    Netind = find(Net_unrl_stim_lags(:,stim)>=-lim & Net_unrl_stim_lags(:,stim)<=lim);
    dat = squeeze(Net_unrl_stim(:,Netind,stim));
    % [Fdat_Net_unrl_stim{stim},f_Net_unrl_stim{stim}] = pwelch(dat(CNodes,:)',sig_fs(stim));
    % [Fdat_Net_unrl_stim(:,:,stim),f_Net_unrl_stim(:,stim)] = pyulear(dat(CNodes,:)',10,nfft,sig_fs(stim));
    [f_Net_unrl_stim(stim,:),~,Fdat_Net_unrl_stim(stim,:),~] = FrequencyDomain(sig_fs(stim),mean(dat(CNodes,:))-mean(mean(dat(CNodes,:))),flag);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(Net_unrl_out) %%%%%%%%%%%%%%%
    Netind = find(Net_unrl_out_lags(:,stim)>=-lim & Net_unrl_out_lags(:,stim)<=lim);
    dat = squeeze(Net_unrl_out(:,Netind,stim));
    % [Fdat_Net_unrl_out{stim},f_Net_unrl_out{stim}] = pwelch(dat(CNodes,:)',sig_fs(stim));
    % [Fdat_Net_unrl_out(:,:,stim),f_Net_unrl_out(:,stim)] = pyulear(dat(CNodes,:)',10,nfft,sig_fs(stim));
    [f_Net_unrl_out(stim,:),~,Fdat_Net_unrl_out(stim,:),~] = FrequencyDomain(sig_fs(stim),mean(dat(CNodes,:))-mean(mean(dat(CNodes,:))),flag);
end
%% Plot EEG: Average across all the subjects
% [EEGm_dat1,EEGsem_dat1,EEGm_dat2,EEGsem_dat2,EEGm_dat3,EEGsem_dat3] = deal(zeros(num_stim,39));
close all
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
    %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEGind = find(EEG_rl_stim_lags(:,stim)>=-lim & EEG_rl_stim_lags(:,stim)<=lim);
    EEGind = EEGind(1:39);
    dat = squeeze(EEG_rl_stim(:,EEGind,stim));
    % [Fdat_EEG_rl_stim{stim},f_EEG_rl_stim{stim}] = pwech(dat',sig_fs(stim));
    % [Fdat_EEG_rl_stim(:,:,stim),f_EEG_rl_stim(:,stim)] = pyulear(dat',10,nfft,sig_fs(stim));
    [f_EEG_rl_stim(stim,:),~,Fdat_EEG_rl_stim(stim,:),~] = FrequencyDomain(sig_fs(stim),mean(dat)-mean(mean(dat)),flag);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(EEG_unrl_stim) %%%%%%%%%%%%%%
    EEGind = find(EEG_unrl_stim_lags(:,stim)>=-lim & EEG_unrl_stim_lags(:,stim)<=lim);
    EEGind = EEGind(1:39);
    dat = squeeze(EEG_unrl_stim(:,EEGind,stim));
    % [Fdat_EEG_unrl_stim{stim},f_EEG_unrl_stim{stim}] = pwech(dat',sig_fs(stim));
    % [Fdat_EEG_unrl_stim(:,:,stim),f_EEG_unrl_stim(:,stim)] = pyulear(dat',10,nfft,sig_fs(stim));
    [f_EEG_unrl_stim(stim,:),~,Fdat_EEG_unrl_stim(stim,:),~] = FrequencyDomain(sig_fs(stim),mean(dat)-mean(mean(dat)),flag);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(EEG_unrl_out) %%%%%%%%%%%%%%%
    EEGind = find(EEG_unrl_out_lags(:,stim)>=-lim & EEG_unrl_out_lags(:,stim)<=lim);
    EEGind = EEGind(1:39);
    dat = squeeze(EEG_unrl_out(:,EEGind,stim));
    % [Fdat_EEG_unrl_out{stim},f_EEG_unrl_out{stim}] = pwech(dat',sig_fs(stim));
    % [Fdat_EEG_unrl_out(:,:,stim),f_EEG_unrl_out(:,stim)] = pyulear(dat',10,nfft,sig_fs(stim));
    [f_EEG_unrl_out(stim,:),~,Fdat_EEG_unrl_out(stim,:),~] = FrequencyDomain(sig_fs(stim),mean(dat)-mean(mean(dat)),flag);
end
%% Average power across stimuli
m_Net_rl_stim = mean(Fdat_Net_rl_stim.^2);
sem_Net_rl_stim = std(Fdat_Net_rl_stim.^2,0,1)./sqrt(num_stim);
m_Net_unrl_stim = mean(Fdat_Net_unrl_stim.^2);
sem_Net_unrl_stim = std(Fdat_Net_unrl_stim.^2,0,1)./sqrt(num_stim);
m_Net_unrl_out = mean(Fdat_Net_unrl_out.^2);
sem_Net_unrl_out = std(Fdat_Net_unrl_out.^2,0,1)./sqrt(num_stim);
% f_Net = mean(f_Net_unrl_out); f_Net = f_Net(length(f_Net)/2:length(f_Net));
m_EEG_rl_stim = mean(Fdat_EEG_rl_stim.^2);
sem_EEG_rl_stim = std(Fdat_EEG_rl_stim.^2,0,1)./sqrt(num_stim);
m_EEG_unrl_stim = mean(Fdat_EEG_unrl_stim.^2);
sem_EEG_unrl_stim = std(Fdat_EEG_unrl_stim.^2,0,1)./sqrt(num_stim);
m_EEG_unrl_out = mean(Fdat_EEG_unrl_out.^2);
sem_EEG_unrl_out = std(Fdat_EEG_unrl_out.^2,0,1)./sqrt(num_stim);
% f_EEG = mean(f_EEG_unrl_out); f_EEG = f_EEG(length(f_EEG)/2:length(f_EEG));
N = 2^nextpow2(39); f = (0:N/2).*mean(sig_fs)/N;

figure('units','normalized','outerposition',[0 0 .4 1])
subplot(2,1,1)
h1 = shadedErrorBar(f,m_Net_rl_stim,sem_Net_rl_stim,'k',1);hold on
h2 = shadedErrorBar(f,m_Net_unrl_stim,sem_Net_unrl_stim,'r',1);hold on
h3 = shadedErrorBar(f,m_Net_unrl_out,sem_Net_unrl_out,'g',1);
title('PSD of Net xcorr grand-averaged across stimuli');grid on
xlabel('Freq (Hz)');ylabel({'Average PSD of xcorr over 80% of nodes','and all stimuli'})
legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output',...
    '1unrelated stim-output','stim-1unrelated outputs')

subplot(2,1,2)
h1 = shadedErrorBar(f,m_EEG_rl_stim,sem_EEG_rl_stim,'k',1);hold on
h2 = shadedErrorBar(f,m_EEG_unrl_stim,sem_EEG_unrl_stim,'r',1);hold on
h3 = shadedErrorBar(f,m_EEG_unrl_out,sem_EEG_unrl_out,'g',1);
title('PSD of EEG xcorr grand-averaged across stimuli');grid on
xlabel('Freq (Hz)');ylabel({'Average PSD of xcorr over all subjects','and all stimuli'})
legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-EEG',...
    '1unrelated stim-EEG','stim-1unrelated EEG')
%% save plot
cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
save_plot(gcf,'mean_sem_xcorr_env_Net_EEG_AveragedAcrossStim_FreqD')
