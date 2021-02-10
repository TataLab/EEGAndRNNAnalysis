% This code finds the frequency representation of data and looks at the
% power spectral density as well;
% Data is the output of recurrecnt layer of the network which Lukas gave me.
% Shweta's data were used as the input to the network
%
%
% @May 2020 - SH

clc; clear; close all;
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas';
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Sylvain'))
load([MatlabRoot '/Data/AllStimuliforExp2WithEmbeddings'])
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
%% Preparing variables
data = myEmbeddings;
num_stim = length(myEmbeddings);
num_neurons = size(myEmbeddings{1},2);
% Computing sampling rate:
original_fs = 16e3;   % This is the sampling rate of the input not the output of the network!
% but the new sampling rate should be computed based on the number of
% samples in the inpt layer and the output layer.

[fs,numSamples1,numSamples2] = deal(zeros(1,num_stim));
for stim = 1:num_stim
    numSamples1(stim) = length(mySoundData{stim});
    numSamples2(stim) = size(myEmbeddings{stim},1);
    fs(stim) = original_fs*numSamples2(stim)/numSamples1(stim);
end
%% fft
[f,s_amp,d_amp] = deal(cell(1,num_stim)); % origina, word shuffled, and phoneme shuffled
for stim = 1:num_stim
    for nron = 1:num_neurons
        x = data{stim}(:,nron)';
        [f{stim},~,s_amp{stim}(nron,:),d_amp{stim}(nron,:)] = FrequencyDomain(fs(stim),x-mean(x),0);
    end
end
%% Visualization of the power (fft.^2)
% This estimation is not the best estimation of the PSD
m=20; Mx = [];
for stim = 1:num_stim
    Mx=[Mx,s_amp{stim}(:).^2];
end
Mx = prctile(Mx(:),95);
for stim = 1:num_stim
    N = numel(f{stim});
    figure(stim);clf;
    ax1 = axes; hold on
    ax2 = axes;
    imagesc(s_amp{stim}.^2,[0,Mx]); axis xy;axis off
    c = colorbar; c.Location = 'eastoutside';
    pos=get(ax2,'pos');
    set(ax1,'pos',pos);
    set(ax1,'xtick',linspace(0,1,numel(N/2:m:N)), 'xticklabels', round(f{stim}(N/2:m:N)))
    set(ax1,'ytick',1, 'yticklabels', num_neurons)
    title(['Power for stim ' num2str(stim)]);
    set(get(ax1,'XLabel'),'String','Freq (Hz)')
    set(get(ax1,'YLabel'),'String','Node')
    cd([MatlabRoot , '/Result/FreqPower_Node'])
    save_plot(gcf,['FreqPowerNode_Stim' num2str(stim)])
end
close all
%% Visualization of the power in db
m=20; 
% Mx = [];
% for stim = 1:num_stim
%     Mx=[Mx,10*log10(s_amp{stim}(:).^2)];
% end
% Mx = prctile(Mx(:),95);
for stim = 1:num_stim
    N = numel(f{stim});
    figure(stim);clf;
    ax1 = axes; hold on
    ax2 = axes;
    imagesc(10*log10(s_amp{stim}.^2)); axis xy;axis off
    c = colorbar; c.Location = 'eastoutside';
    pos=get(ax2,'pos');
    set(ax1,'pos',pos);
    set(ax1,'xtick',linspace(0,1,numel(N/2:m:N)), 'xticklabels', round(f{stim}(N/2:m:N)))
    set(ax1,'ytick',1, 'yticklabels', num_neurons)
    title(['Power(dB) for stim ' num2str(stim)]);ylabel('Node');xlabel('Freq (Hz)')
    cd([MatlabRoot , '/Result/FreqPower_Node'])
    save_plot(gcf,['dB_FreqPowerNode_Stim' num2str(stim)])
end
% close all
%% save
cd([MatlabRoot , '/Result/FreqPower_Node'])
save('FreqDomainRep')
%% Average the power over all the nodes
p = zeros(num_stim,size(s_amp{1},2));
for stim = 1:num_stim
    p(stim,:) = sum(s_amp{stim}.^2,1);
end
%% Plot and save
figure('units','normalized','outerposition',[0 0 1 .9])
subplot(2,2,1)
plot(f{stim}(N/2:N),p);
xlabel('Freq(Hz)');ylabel('Power');xlim([0,25])
title({'Averaged over all the nodes but','separately plotted for each stim'})
subplot(2,2,2)
plot(f{stim}(N/2:N),mean(p,1),'LineWidth',2);
xlabel('Freq(Hz)');ylabel('Power');xlim([0,25])
title('averaged over the nodes and stimuli')
%% PSD using Yule-Walker method
subplot(2,2,3);
color = linspecer(num_stim);
mmpxx = zeros(33,1);
for stim = 1:num_stim
    x = data{stim}-mean(data{stim},1).*ones(size(data{stim}));
    [pxx{stim},nf(:,stim)] = pyulear(x,150,2^6,fs(stim));
    hold on; plot(nf(:,stim),10*log10(mean(pxx{stim},2)),'Color',color(stim,:))
    mmpxx = mmpxx+mean(pxx{stim},2);
end
xlabel('Freq(Hz)');ylabel('Yule-walker PSD (dB/Hz)');xlim([0,25])
title({'Averaged over all the nodes but','separately plotted for each stim'})
subplot(2,2,4);
plot(nf(:,1),10*log10(mmpxx),'LineWidth',2);xlim([0,25])
xlabel('Freq(Hz)');ylabel('Yule-walker PSD (dB/Hz)');
title('averaged over the nodes and stimuli')
%% save plot
cd([MatlabRoot , '/Result/FreqPower_Node'])
save_plot(gcf,'Collapsed_FreqPower')

