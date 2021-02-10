% This codes read the corr matrices saved by 'RSA_NB_EEG_and_Net.m'
% and Plots corr-coef of each layer of the net with the EEG in different freq bands.
% 
% 
% @June - SH

%% Initialisation %%
%%%%%%%%%%%%%%%%%%%%
clc; clear; close all
toolboxRoot = '/Volumes/EEGlab_SH/Saeedeh/rsatoolbox-develop/';
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(toolboxRoot));
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
%% Variables %%
%%%%%%%%%%%%%%%
num_subj = 16;      % EEG var: Native speakers only
num_rep = 4;        % EEG var: number of repetitions (which will be assumed as session later in the RDM analysis)
num_trials = 100;   % EEG var
trial_length = 8.5; % EEG var: unit(sec)
num_flt = 10; 
BW = 2; % narrwo-band filter for 2Hz BW
cte = 1; fltName = cell(1,10);
fltName{1} = 'LPF2Hz';
figure(1);set(gcf,'units','normalized','outerposition',[0 0 .8 1])
figure(2);set(gcf,'units','normalized','outerposition',[0 0 1 .7])
color = linspecer(3); [h1,h2] = deal(zeros(1,3));
for ii = 2:2:18
    cte = cte+1;
    fltName{cte} = ['BPF' num2str(ii) 'to' num2str(ii+BW)];
end
for Net = 1:3 % 1 for TrianedNet, 2 for RandomNet, 3 for PhonemeNet
    cd([MatlabRoot 'Data'])
    FileNames = {'TrainedNet','RandomNet','PhonemeNet'};
    load([FileNames{Net} 'Variables.mat'])


    %% Load data and put in a matrix
    [Crr_corr, Crr_euclidean] = deal(zeros(num_layers,num_flt));
    cd([MatlabRoot 'Result/RSA/Statistics'])
    for flt = 1:num_flt
        load([fltName{flt} '_EEG&' FileNames{Net} '_corr_secondOrderSM.mat'])
        Crr_corr(:,flt) = corrMat(end,1:num_layers);
        clear corrMat
        
        load([fltName{flt} '_EEG&' FileNames{Net} '_euclidean_secondOrderSM.mat'])
        Crr_euclidean(:,flt) = corrMat(end,1:num_layers);
        clear corrMat
    end
    %% Plot
    figure(1)
    subplot(3,2,2*Net-1);
    plot(1:2:20,Crr_corr,'LineWidth',1.5);
    xlim([0,20]);ylim([-.2,.5]);xticks(3:2:19);grid on
    legend ('Layer 1','Layer 2','Layer 3','Layer RNN','Layer 5','Layer 6','Location', 'northeastout')
    title(FileNames{Net})
    subplot(3,2,2*Net);
    plot(1:2:20,Crr_euclidean,'LineWidth',1.5);
    xlim([0,20]);ylim([-.2,.5]);xticks(3:2:19);grid on
    legend ('Layer 1','Layer 2','Layer 3','Layer RNN','Layer 5','Layer 6','Location', 'northeastout')
    title(FileNames{Net})
    %% Plot
    figure(2)
    for lay = 1:6
        subplot(2,6,lay);hold on;grid on
        h1(Net) = plot(1:2:20,Crr_corr(lay,:),'Color',color(Net,:),'LineWidth',1.5);
        title(['Layer ' LayerNames{lay}]);xlabel('Freq (Hz)');
        xlim([0,20]);ylim([-.2,.5]);xticks(3:2:19);grid on
        subplot(2,6,6+lay);hold on;grid on
        h2(Net) = plot([1, 3:2:20],Crr_euclidean(lay,:),'Color',color(Net,:),'LineWidth',1.5);
        title(['Layer ' LayerNames{lay}]);xlabel('Freq (Hz)');
        xlim([0,20]);ylim([-.2,.5]);xticks(3:2:19);grid on
    end
end
figure(1)
subplot(3,2,5);    
xlabel('Freq (Hz)');ylabel({'Spearman corrcoef between','the corr RDMs of net & EEG signals'})
subplot(3,2,6);  
xlabel('Freq (Hz)');ylabel({'Spearman corrcoef between','the euclidean RDMs of net & EEG signals'})

figure(2)
subplot(2,6,6);
legend (h1,FileNames{:})
subplot(2,6,1);
ylabel({'Spearman corrcoef between','the corr RDMs of net & EEG signals'})

subplot(2,6,12);
legend (h2,FileNames{:})
subplot(2,6,7);
ylabel({'Spearman corrcoef between','the euclidean RDMs of net & EEG signals'})

%% save
cd([MatlabRoot 'Result/RSA/RDM_narrowBandEEG'])
figure(1);save_plot(gcf,'CompareRDMs1')
figure(2);save_plot(gcf,'CompareRDMs2')