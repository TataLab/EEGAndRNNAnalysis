clc; clear; close all;
MatlabRoot = '/media/lukas/EEGlab_SH/Saeedeh/Saeedeh_Lukas';
addpath(genpath(MatlabRoot));
addpath(genpath('/media/lukas/EEGlab_SH/Saeedeh/Saeedeh_Sylvain'))
load([MatlabRoot '/Data/AllStimuliforExp2WithEmbeddings'])
addpath(genpath('/media/lukas/EEGlab_SH/Saeedeh/lib'))
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
MatlabRoot = '/media/lukas/EEGlab_SH/Saeedeh/Saeedeh_Lukas';
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
% load('xcorr_env_Net_EEG') % similar to zscored_xcorr_env_Net_EEG but with
% no zscore
load('zscored_xcorr_env_Net_EEG')
%% Plot Network: Average across a group of neurons
[Netm_dat1,Netsem_dat1,Netm_dat2,Netsem_dat2,Netm_dat3,Netsem_dat3] = deal(zeros(num_stim,39));
close all
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
    figure(stim);clf
    %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Netind = find(Net_rl_stim_lags(:,stim)>=-lim & Net_rl_stim_lags(:,stim)<=lim);
    dat = squeeze(Net_rl_stim(:,Netind,stim));
    % Choosing the 80% of nodes with higher maximum magnitudes in the selected window
    [mdat,I] = max(abs(dat),[],2);
    Mx = prctile(mdat,20); 
    CNodes = I(mdat>Mx);
    Netm_dat1(stim,:) = mean(dat(CNodes,:));
    Netsem_dat1(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t1 = Net_rl_stim_lags(Netind,stim)*1e3/sig_fs(stim);
    h1 = shadedErrorBar(t1,Netm_dat1(stim,:),Netsem_dat1(stim,:),'k',1);hold on
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(Net_unrl_stim) %%%%%%%%%%%%%%
    Netind = find(Net_unrl_stim_lags(:,stim)>=-lim & Net_unrl_stim_lags(:,stim)<=lim);
    dat = squeeze(Net_unrl_stim(:,Netind,stim));
    Netm_dat2(stim,:) = mean(dat(CNodes,:));
    Netsem_dat2(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t1 = Net_unrl_stim_lags(Netind,stim)*1e3/sig_fs(stim);
    h2 = shadedErrorBar(t1,Netm_dat2(stim,:),Netsem_dat2(stim,:),'r',1);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(Net_unrl_out) %%%%%%%%%%%%%%%
    Netind = find(Net_unrl_out_lags(:,stim)>=-lim & Net_unrl_out_lags(:,stim)<=lim);
    dat = squeeze(Net_unrl_out(:,Netind,stim));
    Netm_dat3(stim,:) = mean(dat(CNodes,:));
    Netsem_dat3(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t1 = Net_unrl_out_lags(Netind,stim)*1e3/sig_fs(stim);
    h3 = shadedErrorBar(t1,Netm_dat3(stim,:),Netsem_dat3(stim,:),'g',1);
    %%%%%%%%%%%%%%%%%%%% save plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    title(['xcorr for stim ' num2str(stim)]);
    xlabel('lag (msec)');ylabel('Average xcorr over 80% of nodes')
    legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output','unrelated stim-output','stim-unrelated outputs')
    cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
%     save_plot(gcf,'')
end
%% Plot EEG: Average across all the subjects
[EEGm_dat1,EEGsem_dat1,EEGm_dat2,EEGsem_dat2,EEGm_dat3,EEGsem_dat3] = deal(zeros(num_stim,39));
close all
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
    figure(stim);clf
    %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEGind = find(EEG_rl_stim_lags(:,stim)>=-lim & EEG_rl_stim_lags(:,stim)<=lim);
    EEGind = EEGind(1:39);
    dat = squeeze(EEG_rl_stim(:,EEGind,stim));
    EEGm_dat1(stim,:) = mean(dat);
    EEGsem_dat1(stim,:) = std(dat,[],1)/sqrt(size(dat,1));
    t2 = EEG_rl_stim_lags(EEGind,stim)*1e3/sig_fs(stim); t2 = t2(1:39);
    h1 = shadedErrorBar(t2,EEGm_dat1(stim,:),EEGsem_dat1(stim,:),'k',1);hold on
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(EEG_unrl_stim) %%%%%%%%%%%%%%
    EEGind = find(EEG_unrl_stim_lags(:,stim)>=-lim & EEG_unrl_stim_lags(:,stim)<=lim);
    EEGind = EEGind(1:39);
    dat = squeeze(EEG_unrl_stim(:,EEGind,stim));
    EEGm_dat2(stim,:) = mean(dat);
    EEGsem_dat2(stim,:) = std(dat,[],1)/sqrt(size(dat,1));
    t2 = EEG_unrl_stim_lags(EEGind,stim)*1e3/sig_fs(stim); t2 = t2(1:39);
    h2 = shadedErrorBar(t2,EEGm_dat2(stim,:),EEGsem_dat2(stim,:),'r',1);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(EEG_unrl_out) %%%%%%%%%%%%%%%
    EEGind = find(EEG_unrl_out_lags(:,stim)>=-lim & EEG_unrl_out_lags(:,stim)<=lim);
    EEGind = EEGind(1:39);
    dat = squeeze(EEG_unrl_out(:,EEGind,stim));
    EEGm_dat3(stim,:) = mean(dat);
    EEGsem_dat3(stim,:) = std(dat,[],1)/sqrt(size(dat,1));
    t2 = EEG_unrl_out_lags(EEGind,stim)*1e3/sig_fs(stim); t2 = t2(1:39);
    h3 = shadedErrorBar(t2,EEGm_dat3(stim,:),EEGsem_dat3(stim,:),'g',1);
    %%%%%%%%%%%%%%%%%%%% save plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    title(['xcorr for stim ' num2str(stim)]);
    xlabel('lag (msec)');ylabel('Average xcorr over all the aubjects')
    legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output','unrelated stim-output','stim-unrelated outputs')
    cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
%     save_plot(gcf,'')
end
%% Average across stimuli
% close all
figure('units','normalized','outerposition',[0 0 .4 1])
clear h1 h2 h3
subplot(2,1,1)
h1 = shadedErrorBar(t1,mean(Netm_dat1,1),std(Netm_dat1,[],1)./sqrt(num_stim),'k',1);hold on
h2 = shadedErrorBar(t1,mean(Netm_dat2,1),std(Netm_dat2,[],1)./sqrt(num_stim),'r',1);hold on
h3 = shadedErrorBar(t1,mean(Netm_dat3,1),std(Netm_dat3,[],1)./sqrt(num_stim),'g',1);
title('Net xcorr grant-averaged across stimuli');
xlabel('lag (msec)');ylabel({'Average xcorr over 80% of nodes','and all stimuli'})
legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output',...
    '1unrelated stim-output','stim-1unrelated outputs','Location','southwest')

subplot(2,1,2)
h1 = shadedErrorBar(t2,mean(EEGm_dat1,1),std(EEGm_dat1,[],1)./sqrt(num_stim),'k',1);hold on
h2 = shadedErrorBar(t2,mean(EEGm_dat2,1),std(EEGm_dat2,[],1)./sqrt(num_stim),'r',1);hold on
h3 = shadedErrorBar(t2,mean(EEGm_dat3,1),std(EEGm_dat3,[],1)./sqrt(num_stim),'g',1);
title('EEG xcorr grant-averaged across stimuli');
xlabel('lag (msec)');ylabel({'Average xcorr over all subjects','and all stimuli'})
legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-EEG',...
    '1unrelated stim-EEG','stim-1unrelated EEG','Location','southwest')
%% save plot
cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
save_plot(gcf,'zscored_mean_sem_xcorr_env_Net_EEG_AveragedAcrossStim')
%% Pool data of a group of neurons and all the stimuli, then average
[Netdat1,Netdat2,Netdat3] = deal(zeros(num_neurons,39,num_stim));
[EEGdat1,EEGdat2,EEGdat3] = deal(zeros(num_subj-1,39,num_stim));
% pooling data
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag either side
    %%%%%%%%%%%%%%%%%%%% Prepare data of Net %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ind = find(Net_rl_stim_lags(:,stim)>=-lim & Net_rl_stim_lags(:,stim)<=lim);
    Netdat1(:,:,stim) = Net_rl_stim(:,ind,stim);
    ind = find(Net_unrl_stim_lags(:,stim)>=-lim & Net_unrl_stim_lags(:,stim)<=lim);
    Netdat2(:,:,stim) = Net_unrl_stim(:,ind,stim);
    ind = find(Net_unrl_out_lags(:,stim)>=-lim & Net_unrl_out_lags(:,stim)<=lim);
    Netdat3(:,:,stim) = Net_unrl_out(:,ind,stim);
    %%%%%%%%%%%%%%%%%%%% Prepare data of EEG %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ind = find(EEG_rl_stim_lags(:,stim)>=-lim & EEG_rl_stim_lags(:,stim)<=lim);
    ind = ind(1:39);
    EEGdat1(:,:,stim) = EEG_rl_stim(:,ind,stim);
    ind = find(EEG_unrl_stim_lags(:,stim)>=-lim & EEG_unrl_stim_lags(:,stim)<=lim);
    ind = ind(1:39);
    EEGdat2(:,:,stim) = EEG_unrl_stim(:,ind,stim);
    ind = find(EEG_unrl_out_lags(:,stim)>=-lim & EEG_unrl_out_lags(:,stim)<=lim);
    ind = ind(1:39);
    EEGdat3(:,:,stim) = EEG_unrl_out(:,ind,stim);
end
% Choosing the 80% of nodes with higher maximum magnitudes in the selected window
[mdat,I] = max(squeeze(reshape(Netdat1,num_neurons,[],1)),[],2);
Mx = prctile(mdat,20);
CNodes = I(mdat>Mx);
[NetCdat1,NetCdat2,NetCdat3,EEGCdat1,EEGCdat2,EEGCdat3] = deal([]);
for stim = 1:num_stim
    NetCdat1 = [NetCdat1;Netdat1(CNodes,:,stim)];
    NetCdat2 = [NetCdat2;Netdat2(CNodes,:,stim)];
    NetCdat3 = [NetCdat3;Netdat3(CNodes,:,stim)];
    
    EEGCdat1 = [EEGCdat1;EEGdat1(:,:,stim)];
    EEGCdat2 = [EEGCdat2;EEGdat2(:,:,stim)];
    EEGCdat3 = [EEGCdat3;EEGdat3(:,:,stim)];
end
%%%%%%% Mean and SEM of the Net %%%%%%%%%%
Net_m1 = mean(NetCdat1,1);
Net_sem1 = std(NetCdat1,0,1)./sqrt(size(NetCdat1,1));
Net_m2 = mean(NetCdat2,1);
Net_sem2 = std(NetCdat2,0,1)./sqrt(size(NetCdat2,1));
Net_m3 = mean(NetCdat3,1);
Net_sem3 = std(NetCdat3,0,1)./sqrt(size(NetCdat3,1));
%%%%%%% Mean and SEM of the EEG %%%%%%%%%%
EEG_m1 = mean(EEGCdat1,1);
EEG_sem1 = std(EEGCdat1,0,1)./sqrt(size(EEGCdat1,1));
EEG_m2 = mean(EEGCdat2,1);
EEG_sem2 = std(EEGCdat2,0,1)./sqrt(size(EEGCdat2,1));
EEG_m3 = mean(EEGCdat3,1);
EEG_sem3 = std(EEGCdat3,0,1)./sqrt(size(EEGCdat3,1));

t1 = linspace(-400,400,39);
close all
figure('units','normalized','outerposition',[0 0 .4 1])
subplot(2,1,1)
h1 = shadedErrorBar(t1,Net_m1,Net_sem1,'k',1);hold on
h2 = shadedErrorBar(t1,Net_m2,Net_sem2,'r',1);hold on
h3 = shadedErrorBar(t1,Net_m3,Net_sem3,'g',1);hold on
title({'xcorr between StimEnv and NetOut was pooled across', ...
    'all stimuli and 80% neurons and then averaged'});
xlabel('lag (msec)');ylabel('Average xcorr')
legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output',...
    'unrelated stim-output','stim-unrelated outputs','Location','southwest')

subplot(2,1,2)
h1 = shadedErrorBar(t2,EEG_m1,EEG_sem1,'k',1);hold on
h2 = shadedErrorBar(t2,EEG_m2,EEG_sem2,'r',1);hold on
h3 = shadedErrorBar(t2,EEG_m3,EEG_sem3,'g',1);hold on
title({'xcorr between StimEnv and EEG was pooled across',...
    'all stimuli and subjects and then averaged'});
xlabel('lag (msec)');ylabel('Average xcorr')
legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output',...
    'unrelated stim-output','stim-unrelated outputs','Location','southwest')
%% save plot
cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
save_plot(gcf,'zscored_m_xcorr_env_Net_EEG_AvgAcrossStimAndNodesorSubjs')
