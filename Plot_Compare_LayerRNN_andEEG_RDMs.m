%% Initialisation %%
%%%%%%%%%%%%%%%%%%%%
clc; clear; close all
toolboxRoot = '/Volumes/EEGlab_SH/Saeedeh/rsatoolbox-develop/';
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(toolboxRoot));
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))

%% Plot comparison of network RDMs and EEG data only %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd([MatlabRoot 'Data'])
FileNames = {'TrainedNet','RandomNet','PhonemeNet'};
load('TrainedNetVariables.mat')
cd([MatlabRoot 'Result/RSA/Statistics'])
col = linspecer(6);
figure;
h = zeros(1,6);
lgnd = cell(1,6);
for Net = 1:3
    load(['EEGand' FileNames{Net} '_corr_secondOrderSM'])
    h(2*Net-1) = plot(1:num_layers,corrMat(num_layers+1,1:num_layers),'Color',col(2*Net-1,:),'LineWidth',2);
    hold on; clear corrMat
    load(['EEGand' FileNames{Net} '_euclidean_secondOrderSM'])
    h(2*Net) = plot(1:num_layers,corrMat(num_layers+1,1:num_layers),'Color',col(2*Net,:),'LineWidth',2);
    lgnd{2*Net-1} = [FileNames{Net} ' corr RDM'];
    lgnd{2*Net} = [FileNames{Net} ' euclidean RDM'];
end
xlim([0,num_layers+1]);xlabel('Net Layers');ylabel('Spearman corrcoef')
legend(h,lgnd,'Location','NorthWest')
xticks(1:6); xticklabels(LayerNames)
cd([MatlabRoot 'Result/RSA/CompareDistanceMeasures'])
save_plot(gcf,'Compare_NetworkLayers_andEEG_RDMs')