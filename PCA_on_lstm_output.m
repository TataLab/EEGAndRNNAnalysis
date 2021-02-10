clc; clear; close all;
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas';
addpath(genpath(MatlabRoot));
load('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Sylvain/Result/StimInfo')
cd([MatlabRoot '/Results']);
load('lstm_output')
load('shuffled_word_lstm_output.mat')
load('shuffled_phn_lstm_output.mat')
%% PCA on output pf individual spk
% Reminder: [coeff,score,latent] = pca(x);
% x is a matrix of data: space dimension is the number of columns and
% observations are on the row of the matrix
% coeff is the principal component basis vectors
% score is the projection of observations on the new basis vectors
% latent is the variance of x on each basis vector
num_spk = 10;
[coeff,score,latent] = deal(cell(1,num_spk));
col = linspecer(num_spk);
data = {stim_lstm{:};shuffled_word_lstm{:};shuffled_phn_lstm{:}};
tempname = {'original','shffldWRD','shffldPHN'};
figure('units','normalized','position',[.1,.1,.75,.75])
figure('units','normalized','position',[.1,.1,.75,.75])

for ii = 1:3 % we want to repeat the process for the suffled data as well
    fighnd = figure('units','normalized','position',[.1,.1,.75,.75]);
    for spk = 1:num_spk
        [coeff{spk},score{spk},latent{spk}] = pca(data{ii,spk});
        subplot(2,5,spk);
        plot3(score{spk}(:,1),score{spk}(:,2),score{spk}(:,3),...
            'color',col(spk,:),'LineWidth',2);
        title(['Spk#' num2str(spk)]);
        xlabel('PC1')
        ylabel('PC2')
        zlabel('PC3')
    end
    %save
    cd([MatlabRoot '/SaeedehLukas']);
    save_plot(fighnd,[tempname{ii} 'PCAonIndividualStim'])
    %% train the pca with all concatenated data not individual spks and then 
    % plot individual spk on the reduced-dim space
    cnct_data = []; num_obs = zeros(1,num_spk);
    for spk = 1:num_spk
        cnct_data = [cnct_data;data{ii,spk}];
        num_obs(spk) = size(data{ii,spk},1); %number of observations for each spk
    end
    % find the first three neurons in cnct_stim_lstm with maximum variance
    var_cnct_data = var(cnct_data);
    [temp, temp_ind] = sort(var_cnct_data,'descend'); 
    first3max = temp(1:3); first3max_ind = temp_ind(1:3);

    [cnctcoeff,cnctscore,cnctlatent] = pca(cnct_data);
    % now plot the first three PCs for each spk individually
    for spk = 2:num_spk
        begind = sum(num_obs(1:spk))-num_obs(spk)+1;
        endind = sum(num_obs(1:spk));
        figure(1);subplot(2,3,ii);plot3(cnct_data(begind:endind,first3max_ind(1)),...
            cnct_data(begind:endind,first3max_ind(2)),...
            cnct_data(begind:endind,first3max_ind(3)),...
            'color',col(spk,:),'LineWidth',2);hold on
        figure(2);subplot(2,3,ii);plot3(cnctscore(begind:endind,1),cnctscore(begind:endind,2),cnctscore(begind:endind,3),...
            'color',col(spk,:),'LineWidth',2);hold on
    end
    figure(1);subplot(2,3,ii);
    title({tempname{ii} '.All spk but only the first three', 'neurons with maximum variance'});
    xlabel('neuron 1')
    ylabel('neuron 2')
    zlabel('neuron 3')
    subplot(2,3,ii+3); plot(var_cnct_data(temp_ind),'LineWidth',2);
    title([tempname{ii} '.All spk']); xlabel('Sorted neuron numbers');ylabel('Var')

    figure(2);subplot(2,3,ii);
    title([tempname{ii} '.All spk']);
    xlabel('PC1')
    ylabel('PC2')
    zlabel('PC3')
    subplot(2,3,ii+3); plot(cnctlatent,'LineWidth',2);
    title([tempname{ii} '_All spk']); xlabel('PCs');ylabel('Latent var')
end
%% save
cd([MatlabRoot '/SaeedehLukas']);
save_plot(fighnd,[tempname{ii} 'PCAonIndividualStim'])
figure(1);save_plot(gcf,'3Dplot_first3neuronsWithMaxVar')
figure(2);save_plot(gcf,'3Dplot_first3PC')
