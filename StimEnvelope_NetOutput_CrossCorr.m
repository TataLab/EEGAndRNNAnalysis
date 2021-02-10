% This code finds the envelope of stimulus, then calculates the half-wave
% rectification of the first derivative of the envelope. 
% At the end finds the cross correlation with the desired signal, which can
% be EEG or the network output. Here we look at the  network output.
% Shweta's data were used as the input to the network
%
%
% @ May 2020 - SH

clc; clear; close all;
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas';
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Sylvain'))
load([MatlabRoot '/Data/AllStimuliforExp2WithEmbeddings'])
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
%% Preparing variables
num_stim = length(myEmbeddings);
num_neurons = size(myEmbeddings{1},2);
% Computing sampling rate:
stim_fs = 16e3;   % This is the sampling rate of the input not the output of the network!
% but the new sampling rate should be computed based on the number of
% samples in the inpt layer and the output layer.

[sig_fs,numSamples1,numSamples2] = deal(zeros(1,num_stim));
for stim = 1:num_stim
    numSamples1(stim) = length(mySoundData{stim});
    numSamples2(stim) = size(myEmbeddings{stim},1);
    sig_fs(stim) = stim_fs*numSamples2(stim)/numSamples1(stim);
end
%% 1)Calculate the envelope
% [f,s_amp,d_amp] = deal(cell(1,num_stim));
Env = cell(5,num_stim);
for stim = 1:num_stim
    Env{1,stim} = abs(hilbert(mySoundData{stim}));
    
    %     Visulization
    %     t = (0:numSamples1(stim)-1)./stim_fs;
    %     figure; plot(t,mySoundData{stim});hold on;plot(t,Env{1,stim},'or');
    
    %     x = mySoundData{stim};
    %     [f{stim},~,s_amp{stim},d_amp{stim}] = FrequencyDomain(stim_fs,x-mean(x),1);
    %     x = Env{1,stim};
    %     [f{stim},~,s_amp{stim},d_amp{stim}] = FrequencyDomain(stim_fs,x-mean(x),1);
end
%% 2)Low Pass filtering the envelope at 25 Hz
Hd = LPFilt_ForEnv_25_FIR_LeastSqu_ord1000;
for stim = 1:num_stim
    Env{2,stim} = filtfilt(Hd.Numerator,1,Env{1,stim}); %LPF at 25Hz
    
    %     Visulization
    %     t = (0:numSamples1(stim)-1)./stim_fs;
    %     figure; plot(t,mySoundData{stim});hold on;
    %     plot(t,Env{1,stim},'or'); plot(t,Env{2,stim},'.-g');
    
    %     x = Env{1,stim};
    %     [f,~,s_amp,d_amp] = FrequencyDomain(stim_fs,x-mean(x),1);
    %     x = Env{2,stim};
    %     [f,~,s_amp,d_amp] = FrequencyDomain(stim_fs,x-mean(x),1);
end
%% 3)Downsample to the same fs of the other sig in cross-corr
for stim = 1:num_stim
    [p,q] = rat(sig_fs(stim)/stim_fs);
    Env{3,stim} = resample(Env{2,stim},p,q);
    % Visulization
    t = (0:numSamples1(stim)-1)./stim_fs;
    kk = 3000:20000;
    figure; plot(t(kk),mySoundData{stim}(kk));hold on;
    plot(t(kk),Env{1,stim}(kk),'o-r');
    plot(t,Env{2,stim},'.-g');
    plot(linspace(0,t(end),length(Env{3,stim})),Env{3,stim},'.-k');
end
%% 4)First Derivative and positive half-wave rectification
for stim = 1:num_stim
    dy = diff(Env{3,stim});
    dy(dy<0) = 0;
    Env{4,stim} = dy;
    
    %     Visulization
    %     t = (0:numSamples1(stim)-1)./stim_fs;
    %     figure;
    %     plot(t,mySoundData{stim});
    %     hold on;
    %     plot(t,Env{1,stim},'or');
    %     plot(t,Env{2,stim},'.-g');
    %     plot(linspace(0,t(end),length(Env{3,stim})),Env{3,stim},'.-k');
    %     plot(linspace(0,t(end),length(Env{4,stim})),Env{4,stim},'.-c');
end
%% 5)Normalization (to have a summation of 1)
for stim = 1:num_stim
    Env{5,stim} = Env{4,stim}./sum(Env{4,stim});
end

%% Cross Corr with all related and unrelated stimuli
% xcorr with the main stim will be on the diagonal
[CrossCorr_mat,lags] = deal(cell(num_stim,num_stim));
for ii = 1:num_stim % Main stim
    for nron = 1:num_neurons
        x = myEmbeddings{ii}(:,nron)';
        for jj = 1:num_stim % All other stim
            y = Env{5,jj};
            [CrossCorr_mat{ii,jj}(nron,:),lags{ii,jj}] = xcorr(x,y);
        end
    end
    disp(['***** Stim ' num2str(ii) ' done ******'])
end
%% find the minimum size of the matrices in CrossCorr_mat
temp = [];
for ii = 1:num_stim
    for jj = 1:num_stim
        temp = [temp,length(lags{ii,jj})];
    end
end
mn = min(temp);
%% Average over the xcorr of an output of the network with unrelated stimuli only
m_unrl_stim = cell(1,num_stim);
for ii = 1:num_stim % Main stim
    m_unrl_stim{ii} = zeros(num_neurons,mn);
    for jj = 1:num_stim % All other stim
        m_unrl_stim{ii} = m_unrl_stim{ii}+CrossCorr_mat{ii,jj}(:,1:mn);
    end
    m_unrl_stim{ii} = (m_unrl_stim{ii}-CrossCorr_mat{ii,ii}(:,1:mn))/(num_stim-1);
end
%% Average over the xcorr of an stimulus with unrelated outputs of the network only
m_unrl_out = cell(1,num_stim);
for ii = 1:num_stim % Main stim
    m_unrl_out{ii} = zeros(num_neurons,mn);
    for jj = 1:num_stim % All other stim
        m_unrl_out{ii} = m_unrl_out{ii}+CrossCorr_mat{jj,ii}(:,1:mn);
    end
    m_unrl_out{ii} = (m_unrl_out{ii}-CrossCorr_mat{ii,ii}(:,1:mn))/(num_stim-1);
end
%% Plot
Mx = [];
for stim = 1:num_stim
    Mx=[Mx;CrossCorr_mat{stim,stim}(:)];
end
Mx = prctile(Mx,95);
for stim = 1:num_stim
    figure(stim);clf
    ax1 = axes; hold on
    ax2 = axes;
    imagesc(CrossCorr_mat{stim,stim},[0,Mx]);axis xy; axis off
    c = colorbar; c.Location = 'eastoutside';
    pos=get(ax2,'pos');
    set(ax1,'pos',pos);
    t = lags{stim}(1:100:end)*1e3/sig_fs(stim);
    set(ax1,'xtick',linspace(0,1,numel(t)), 'xticklabels', t)
    set(ax1,'ytick',1, 'yticklabels', num_neurons)
    title(['xcorr for stim ' num2str(stim)]);
    set(get(ax1,'XLabel'),'String','Lag (msec)')
    set(get(ax1,'YLabel'),'String','Node')
    cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
    save_plot(gcf,['xcorr_env_Stim' num2str(stim)])
end
close all
%% Plot in a small window
Mx = [];
for stim = 1:num_stim
    Mx=[Mx;CrossCorr_mat{stim,stim}(:)];
end
Mx = prctile(Mx,95);

for stim = 1%:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
    figure(stim);clf
    ax1 = axes; hold on
    ax2 = axes;
    ind = find(lags{stim}>=0 & lags{stim}<=lim);
    dat = CrossCorr_mat{stim,stim}(:,ind);
    [temp,I] = sort(dat(:,8),'descend');
    sort_dat = dat(I,:);
    imagesc(sort_dat,[0,Mx]); axis xy; axis off
    c = colorbar; c.Location = 'eastoutside';
    pos=get(ax2,'pos');
    set(ax1,'pos',pos);
    t = lags{stim}(ind)*1e3/sig_fs(stim);
    set(ax1,'xtick',linspace(0,1,numel(t)), 'xticklabels', t)
    set(ax1,'ytick',1, 'yticklabels', num_neurons)
    title(['xcorr for stim ' num2str(stim)]);
    set(get(ax1,'XLabel'),'String','Lag (msec)')
    set(get(ax1,'YLabel'),'String','Node')
    cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
%     save_plot(gcf,['xcorr_env_Stim' num2str(stim)])
end
% close all
%% Average over a group of neurons
[m_dat1,sem_dat1,m_dat2,sem_dat2,m_dat3,sem_dat3] = deal(zeros(num_stim,20));
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag
    figure(stim);clf
    ind = find(lags{stim}>=0 & lags{stim}<=lim);
    %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dat = CrossCorr_mat{stim,stim}(:,ind);
    % Choosing the 80% of nodes with higher maximum magnitudes in the selected window
    [mdat,I] = max(dat,[],2);
    Mx = prctile(mdat,20); 
    CNodes = I(mdat>Mx);
    m_dat1(stim,:) = mean(dat(CNodes,:));
    sem_dat1(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t = lags{stim}(ind)*1e3/sig_fs(stim);
    h1 = shadedErrorBar(t,m_dat1(stim,:),sem_dat1(stim,:),'k',1);hold on
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(m_unrl_stim) %%%%%%%%%%%%%%
    dat = m_unrl_stim{stim}(:,ind);
    m_dat2(stim,:) = mean(dat(CNodes,:));
    sem_dat2(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t = lags{stim}(ind)*1e3/sig_fs(stim);
    h2 = shadedErrorBar(t,m_dat2(stim,:),sem_dat2(stim,:),'r',1);
    %%%%%%%%%%%%%%%%%%%% Prepare unrelated data(m_unrl_out) %%%%%%%%%%%%%%%
    dat = m_unrl_out{stim}(:,ind);
    m_dat3(stim,:) = mean(dat(CNodes,:));
    sem_dat3(stim,:) = std(dat(CNodes,:),[],1)/sqrt(size(dat(CNodes,:),1));
    t = lags{stim}(ind)*1e3/sig_fs(stim);
    h3 = shadedErrorBar(t,m_dat3(stim,:),sem_dat3(stim,:),'g',1);
    %%%%%%%%%%%%%%%%%%%% save plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    title(['xcorr for stim ' num2str(stim)]);
    xlabel('lag (msec)');ylabel('Average xcorr over 80% of nodes')
    legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output','unrelated stim-output','stim-unrelated outputs')
    cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
%     save_plot(gcf,['mean_sem_xcorr_env_Stim' num2str(stim)])
end
close all
figure;clf
clear h1 h2 h3
h1 = shadedErrorBar(t,mean(m_dat1,1),std(m_dat1,[],1)./sqrt(num_stim),'k',1);hold on
h2 = shadedErrorBar(t,mean(m_dat2,1),std(m_dat2,[],1)./sqrt(num_stim),'r',1);hold on
h3 = shadedErrorBar(t,mean(m_dat3,1),std(m_dat3,[],1)./sqrt(num_stim),'g',1);
title('xcorr grant-averaged across stimuli');
xlabel('lag (msec)');ylabel('Average xcorr over 80% of nodes')
legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output','unrelated stim-output','stim-unrelated outputs')
cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
save_plot(gcf,'mean_sem_xcorr_env_AveragedAcrossStim')
%% Pool data of a group of neurons and all the stimuli
[dat1,dat2,dat3] = deal(zeros(num_neurons,39,num_stim));
% pooling data
for stim = 1:num_stim
    lim = 400 * 1e-3 * sig_fs(stim);  %~400 msec lag either side
    ind = find(lags{stim}>=-lim & lags{stim}<=lim);
    %%%%%%%%%%%%%%%%%%%% Prepare data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dat1(:,:,stim) = CrossCorr_mat{stim,stim}(:,ind);
    dat2(:,:,stim) = m_unrl_stim{stim}(:,ind);
    dat3(:,:,stim) = m_unrl_out{stim}(:,ind);
    t = lags{stim}(ind)*1e3./sig_fs(stim);
end
% Choosing the 80% of nodes with higher maximum magnitudes in the selected window
[mdat,I] = max(squeeze(reshape(dat1,num_neurons,[],1)),[],2);
Mx = prctile(mdat,20);
CNodes = I(mdat>Mx);
[Cdat1,Cdat2,Cdat3] = deal([]);
for stim = 1:num_stim
    Cdat1 = [Cdat1;dat1(CNodes,:,stim)];
    Cdat2 = [Cdat2;dat2(CNodes,:,stim)];
    Cdat3 = [Cdat3;dat3(CNodes,:,stim)];
end
m_Cdat1 = mean(Cdat1,1);
sem_Cdat1 = std(Cdat1,[],1)./sqrt(size(Cdat1,1));
m_Cdat2 = mean(Cdat2,1);
sem_Cdat2 = std(Cdat2,[],1)./sqrt(size(Cdat2,1));
m_Cdat3 = mean(Cdat3,1);
sem_Cdat3 = std(Cdat3,[],1)./sqrt(size(Cdat3,1));
figure;
h1 = shadedErrorBar(t,m_Cdat1,sem_Cdat1,'k',1);hold on
h2 = shadedErrorBar(t,m_Cdat2,sem_Cdat2,'r',1);hold on
h3 = shadedErrorBar(t,m_Cdat3,sem_Cdat3,'g',1);hold on
%%%%%%%%%%%%%%%%%%%% save plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%
title({'xcorr between StimEnv and NetOut was pooled across all stimuli and neurons', 'and then averaged across 80% of neurons'});
xlabel('lag (msec)');ylabel('Average xcorr')
legend([h1.mainLine,h2.mainLine,h3.mainLine],'stim-output','unrelated stim-output','stim-unrelated outputs')
%% save plot
cd([MatlabRoot , '/Result/Mean_CrossCorr_Envelope'])
save_plot(gcf,'mean_sem_xcorr_env_AvgAcrossStimAndNeurons')
%% save
cd([MatlabRoot , '/Result/CrossCorr_Envelope'])
save('xcorr_env')