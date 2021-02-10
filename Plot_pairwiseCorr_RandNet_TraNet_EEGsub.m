% This codes find the MEAN and SEM of pairwise correlations between the the
% random net and subjects, and plots it for all the layers. 
% The same thing for pairwise correlations between the the
% trained net and subjects. And then statistical comparison between these
% two groups
% @ June 2020 - SH
%% Initialisation %%
%%%%%%%%%%%%%%%%%%%%
clc; clear; close all
toolboxRoot = '/media/lukas/EEGlab_SH/Saeedeh/rsatoolbox-develop/';
MatlabRoot = '/media/lukas/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(toolboxRoot));
addpath(genpath(MatlabRoot));
addpath(genpath('/media/lukas/EEGlab_SH/Saeedeh/lib'))

cd([MatlabRoot 'Result/RSA/Statistics'])
load('corrMats_EEGsubj_TrainedNet_RandNet100')
%% Variables %%
%%%%%%%%%%%%%%%
cd([MatlabRoot 'Data'])
load('RandomNetVariables')
num_shf = 100;

num_subj = 16;      % EEG var: Native speakers only
num_rep = 4;        % EEG var: number of repetitions (which will be assumed as session later in the RDM analysis)
num_trials = 100;   % EEG var
trial_length = 8.5; % EEG var: unit(sec)

%% Main %%
%%%%%%%%%%
EEG_RandNet = zeros(num_subj-1,num_layers,num_shf);
EEG_TraNet = zeros(num_subj-1,num_layers);
for subj = 1:num_subj-1
    for sh = 1:num_shf
        EEG_RandNet(subj,:,sh) = corrMat_EEG_RandomNet{subj,sh}(end,1:num_layers);
    end
    EEG_TraNet(subj,:) = corrMat_EEG_TrainedNet{subj,1}(end,1:num_layers);
end
%% Plot
m1EEG_RandNet = mean(EEG_RandNet,3); % average across the shuffled data
m2EEG_RandNet = mean(m1EEG_RandNet,1);
sem2EEG_RandNet = std(m1EEG_RandNet,0,1)./sqrt((num_subj-1));

mEEG_TraNet = mean(EEG_TraNet,1);
semEEG_TraNet = std(EEG_TraNet,0,1)./sqrt((num_subj-1));

figure;
h1 = shadedErrorBar(1:5,m2EEG_RandNet(1:5),sem2EEG_RandNet(1:5),'r',1);hold on
h2 = shadedErrorBar(1:5,mEEG_TraNet(1:5),semEEG_TraNet(1:5),'k',1);
legend([h1.mainLine,h2.mainLine],'Random Net','Trained Net','location','northwest')
xlim([.5 5.5]);ylim([-.15 .15]);grid on
xticks(1:6); xticklabels(LayerNames)
xlabel('Network Layer');ylabel('Spearman corrcoef between euclidean RDMs')
%% save
cd([MatlabRoot 'Result/RSA/RandomAndTrainedNet'])
save_plot(gcf,'Compare_EEG_RDMswithTrained_and_RandomNet')
%% Stats
p = zeros(1,num_layers);
for lay = 1:num_layers
%     dat = [m1EEG_RandNet(:,lay);EEG_TraNet(:,lay)];
%     grp = [ones(15,1);2*ones(15,1)];
%     [p(lay),tbl,stats] = anova1(dat,grp);
    [h(lay),p(lay),ci,stats] = ttest2(m1EEG_RandNet(:,lay),EEG_TraNet(:,lay));
end