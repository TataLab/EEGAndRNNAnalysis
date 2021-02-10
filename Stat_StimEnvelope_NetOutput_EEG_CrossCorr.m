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
%% Plot EEG: Average across all the subjects
[EEGm_dat1,EEGsem_dat1,EEGm_dat2,EEGsem_dat2] = deal(zeros(num_stim,39));
close all
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
%     figure(stim);clf
    %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEGind = find(EEG_rl_stim_lags(:,stim)>=-lim & EEG_rl_stim_lags(:,stim)<=lim);
    EEGind = EEGind(1:39);
    dat = squeeze(EEG_rl_stim(:,EEGind,stim));
    EEGm_dat1(stim,:) = mean(dat);
    EEGsem_dat1(stim,:) = std(dat,[],1)/sqrt(size(dat,1));
    t2 = EEG_rl_stim_lags(EEGind,stim)*1e3/sig_fs(stim); t2 = t2(1:39);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(EEG_unrl_out) %%%%%%%%%%%%%%%
    EEGind = find(EEG_unrl_out_lags(:,stim)>=-lim & EEG_unrl_out_lags(:,stim)<=lim);
    EEGind = EEGind(1:39);
    dat = squeeze(EEG_unrl_out(:,EEGind,stim));
    EEGm_dat2(stim,:) = mean(dat);
    EEGsem_dat2(stim,:) = std(dat,[],1)/sqrt(size(dat,1));
    t2 = EEG_unrl_out_lags(EEGind,stim)*1e3/sig_fs(stim); t2 = t2(1:39);
end
%% Trained Network: Average across a group of neurons
[TNetm_dat1,TNetsem_dat1,TNetm_dat2,TNetsem_dat2] = deal(zeros(num_stim,39));
close all
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
    %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Netind = find(Net_rl_stim_lags(:,stim)>=-lim & Net_rl_stim_lags(:,stim)<=lim);
    dat = squeeze(Net_rl_stim(:,Netind,stim));
    % Choosing the 80% of nodes with higher maximum magnitudes in the selected window
    [mdat,I] = max(abs(dat),[],2);
    Mx = prctile(mdat,20); 
    CNodes = I(mdat>Mx);
    TNetm_dat1(stim,:) = mean(dat(CNodes,:));
    TNetsem_dat1(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t1 = Net_rl_stim_lags(Netind,stim)*1e3/sig_fs(stim);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(Net_unrl_out) %%%%%%%%%%%%%%%
    Netind = find(Net_unrl_out_lags(:,stim)>=-lim & Net_unrl_out_lags(:,stim)<=lim);
    dat = squeeze(Net_unrl_out(:,Netind,stim));
    TNetm_dat2(stim,:) = mean(dat(CNodes,:));
    TNetsem_dat2(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t1 = Net_unrl_out_lags(Netind,stim)*1e3/sig_fs(stim);
end
%% Random net
% Variables
Net = 2;
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
NetName = {'Trained','Random'};
load('zscored_xcorr_env_RandomNet')
Net_unrl_out = Net_unrl_out./95;
Net_rl_stim = Net_rl_stim./95;
[UNetm_dat1,UNetsem_dat1,UNetm_dat2,UNetsem_dat2] = deal(zeros(num_stim,39));
lay = 4;
close all
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
    %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Netind = find(Net_rl_stim_lags(:,stim)>=-lim & Net_rl_stim_lags(:,stim)<=lim);
    dat = squeeze(Net_rl_stim(:,Netind,stim,lay));
    % Choosing the 80% of nodes with higher maximum magnitudes in the selected window
    [mdat,I] = max(abs(dat),[],2);
    Mx = prctile(mdat,20);
    CNodes = I(mdat>Mx);
    UNetm_dat1(stim,:) = mean(dat(CNodes,:));
    UNetsem_dat1(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t1 = Net_rl_stim_lags(Netind,stim)*1e3/sig_fs(stim);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(Net_unrl_out) %%%%%%%%%%%%%%%
    Netind = find(Net_unrl_out_lags(:,stim)>=-lim & Net_unrl_out_lags(:,stim)<=lim);
    dat = squeeze(Net_unrl_out(:,Netind,stim,lay));
    UNetm_dat2(stim,:) = mean(dat(CNodes,:));
    UNetsem_dat2(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t1 = Net_unrl_out_lags(Netind,stim)*1e3/sig_fs(stim);
end
%% Average across stimuli
%find the peak on EEG data and corresponding time and data point on Net
[EEG_mn,EEG_mn_ind] = min(mean(EEGm_dat1,1));
[EEG_mx,EEG_mx_ind] = max(mean(EEGm_dat1,1));

close all
figure('units','normalized','outerposition',[0 0 .4 1])
% clear h1 h2 h3
subplot(3,1,1)
h1 = shadedErrorBar(t2,mean(EEGm_dat1,1),std(EEGm_dat1,[],1)./sqrt(num_stim),'k',1);hold on
h2 = shadedErrorBar(t2,mean(EEGm_dat2,1),std(EEGm_dat2,[],1)./sqrt(num_stim),'g',1);
title('EEG xcorr grant-averaged across stimuli');
xlabel('lag (msec)');ylabel({'Average xcorr over all subjects','and all stimuli'})
legend([h1.mainLine,h2.mainLine],'stim-EEG',...
    'stim-1unrelated EEG','Location','southwest')
plot([t2(EEG_mn_ind),t2(EEG_mx_ind)],[EEG_mn,EEG_mx],'*r','markersize',6)
m1 = mean(EEGm_dat2,1);
plot([t2(EEG_mn_ind),t2(EEG_mx_ind)],[m1(EEG_mn_ind),m1(EEG_mx_ind)],'*r','markersize',6)

subplot(3,1,2)
h1 = shadedErrorBar(t1,mean(TNetm_dat1,1),std(TNetm_dat1,[],1)./sqrt(num_stim),'k',1);hold on
h2 = shadedErrorBar(t1,mean(TNetm_dat2,1),std(TNetm_dat2,[],1)./sqrt(num_stim),'g',1);
title('Net xcorr grant-averaged across stimuli');
xlabel('lag (msec)');ylabel({'Average xcorr over 80% of nodes','and all stimuli'})
legend([h1.mainLine,h2.mainLine],'stim-output',...
   'stim-1unrelated outputs','Location','southwest')
m2 = mean(TNetm_dat1,1);
plot([t1(EEG_mn_ind-1),t1(EEG_mx_ind-1)],[m2(EEG_mn_ind-1),m2(EEG_mx_ind-1)],'*r','markersize',6)
m3 = mean(TNetm_dat2,1);
plot([t1(EEG_mn_ind-1),t1(EEG_mx_ind-1)],[m3(EEG_mn_ind-1),m3(EEG_mx_ind-1)],'*r','markersize',6)
% The reason for subtracting 1 from EEG_mx_ind is that EEN and Net
% timepoints are not exactly aligned, so I chose the closest one

subplot(3,1,3)
h1 = shadedErrorBar(t1,mean(UNetm_dat1,1),std(UNetm_dat1,[],1)./sqrt(num_stim),'k',1);hold on
h2 = shadedErrorBar(t1,mean(UNetm_dat2,1),std(UNetm_dat2,[],1)./sqrt(num_stim),'g',1);
title('Net xcorr grant-averaged across stimuli');
xlabel('lag (msec)');ylabel({'Average xcorr over 80% of nodes','and all stimuli'})
legend([h1.mainLine,h2.mainLine],'stim-output',...
   'stim-1unrelated outputs','Location','southwest')
m4 = mean(UNetm_dat1,1);
plot([t1(EEG_mn_ind-1),t1(EEG_mx_ind-1)],[m4(EEG_mn_ind-1),m4(EEG_mx_ind-1)],'*r','markersize',6)
m5 = mean(UNetm_dat2,1);
plot([t1(EEG_mn_ind-1),t1(EEG_mx_ind-1)],[m5(EEG_mn_ind-1),m5(EEG_mx_ind-1)],'*r','markersize',6)
% The reason for subtracting 1 from EEG_mx_ind is that EEN and Net
% timepoints are not exactly aligned, so I chose the closest one

%% Stat at EEG peak
% Stat on the peak of EEG and Net
[TNetmn_h,TNetmn_p,TNetmn_ci,TNetmn_stats] = ttest2(TNetm_dat1(:,EEG_mn_ind-1),TNetm_dat2(:,EEG_mn_ind-1));
[UNetmn_h,UNetmn_p,UNetmn_ci,UNetmn_stats] = ttest2(UNetm_dat1(:,EEG_mn_ind-1),UNetm_dat2(:,EEG_mn_ind-1));
[EEGmn_h,EEGmn_p,EEGmn_ci,EEGmn_stats] = ttest2(EEGm_dat1(:,EEG_mn_ind),EEGm_dat2(:,EEG_mn_ind));

[TNetmx_h,TNetmx_p,TNetmx_ci,TNetmx_stats] = ttest2(TNetm_dat1(:,EEG_mx_ind-1),TNetm_dat2(:,EEG_mx_ind-1));
[UNetmx_h,UNetmx_p,UNetmx_ci,UNetmx_stats] = ttest2(UNetm_dat1(:,EEG_mx_ind-1),UNetm_dat2(:,EEG_mx_ind-1));
[EEGmx_h,EEGmx_p,EEGmx_ci,EEGmx_stats] = ttest2(EEGm_dat1(:,EEG_mx_ind),EEGm_dat2(:,EEG_mx_ind));
