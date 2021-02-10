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
num_stim = 25;
num_lay = 5;
Net = input('Which net? (1 for Trained and 2 for Random net): ');    %1 for Trained and 2 for Random net
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
NetName = {'Trained','Random'};
load(['zscored_xcorr_env_', NetName{Net}, 'Net'])
LayerNames = {'Layer 1','Layer 2','Layer 3','Layer RNN', 'Layer 5'};
% Net_unrl_stim = Net_unrl_stim./95;
% Net_unrl_out = Net_unrl_out./95;
% Net_rl_stim = Net_rl_stim./95;
%% Plot Network: Average across a group of neurons
[Netm_dat1,Netsem_dat1,Netm_dat2,Netsem_dat2,Netm_dat3,Netsem_dat3] = deal(zeros(num_stim,39,num_lay));

for lay = 1:num_lay
    close all
    for stim = 1:num_stim
        lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
%         figure(stim);clf
        %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Netind = find(Net_rl_stim_lags(:,stim)>=-lim & Net_rl_stim_lags(:,stim)<=lim);
        dat = squeeze(Net_rl_stim(:,Netind,stim,lay));
        % Choosing the 80% of nodes with higher maximum magnitudes in the selected window
        [mdat,I] = max(abs(dat),[],2);
        Mx = prctile(mdat,20);
        CNodes = I(mdat>Mx);
        Netm_dat1(stim,:,lay) = mean(dat(CNodes,:));
        Netsem_dat1(stim,:,lay) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
        t1 = Net_rl_stim_lags(Netind,stim)*1e3/sig_fs(stim);
%         h1 = shadedErrorBar(t1,Netm_dat1(stim,:,lay),Netsem_dat1(stim,:,lay),'k',1);hold on
        %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(Net_unrl_stim) %%%%%%%%%%%%%%
        Netind = find(Net_unrl_stim_lags(:,stim)>=-lim & Net_unrl_stim_lags(:,stim)<=lim);
        dat = squeeze(Net_unrl_stim(:,Netind,stim,lay));
        Netm_dat2(stim,:,lay) = mean(dat(CNodes,:));
        Netsem_dat2(stim,:,lay) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
        t1 = Net_unrl_stim_lags(Netind,stim)*1e3/sig_fs(stim);
%         h2 = shadedErrorBar(t1,Netm_dat2(stim,:,lay),Netsem_dat2(stim,:,lay),'r',1);
        %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(Net_unrl_out) %%%%%%%%%%%%%%%
        Netind = find(Net_unrl_out_lags(:,stim)>=-lim & Net_unrl_out_lags(:,stim)<=lim);
        dat = squeeze(Net_unrl_out(:,Netind,stim,lay));
        Netm_dat3(stim,:,lay) = mean(dat(CNodes,:));
        Netsem_dat3(stim,:,lay) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
        t1 = Net_unrl_out_lags(Netind,stim)*1e3/sig_fs(stim);
%         h3 = shadedErrorBar(t1,Netm_dat3(stim,:,lay),Netsem_dat3(stim,:,lay),'g',1);
        %%%%%%%%%%%%%%%%%%%% save plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         title(['xcorr for stim ' num2str(stim)]);
%         xlabel('lag (msec)');ylabel('Average xcorr over 80% of nodes')
%         legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output','unrelated stim-output','stim-unrelated outputs')
%         cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
        %     save_plot(gcf,'')
    end
    disp(['****** Layer ' num2str(lay) ' is done ******'])
end

%% Average across stimuli
figure('units','normalized','outerposition',[0 0 1 .4])
% clear h1 h2 h3
for lay = 1:num_lay
    subplot(1,num_lay,lay)
    h1 = shadedErrorBar(t1,mean(Netm_dat1(:,:,lay),1),std(Netm_dat1(:,:,lay),[],1)./sqrt(num_stim),'k',1);hold on
    h2 = shadedErrorBar(t1,mean(Netm_dat2(:,:,lay),1),std(Netm_dat2(:,:,lay),[],1)./sqrt(num_stim),'r',1);hold on
    h3 = shadedErrorBar(t1,mean(Netm_dat3(:,:,lay),1),std(Netm_dat3(:,:,lay),[],1)./sqrt(num_stim),'g',1);
    title([LayerNames{lay} ' of the' NetName{Net} ' net']);
    xlabel('lag (msec)'); xlim([-400,400]);ylim([-10,10])
    if lay == 1
        legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output',...
        '1unrelated stim-output','stim-1unrelated outputs','Location','southwest')
    end
end
subplot(1,num_lay,1);ylabel({'Average xcorr over 80% of nodes','and all stimuli'})
%% save plot
cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
save_plot(gcf,['zscored_mean_sem_xcorr_env_',NetName{Net},'Net_EEG_AveragedAcrossStim'])
