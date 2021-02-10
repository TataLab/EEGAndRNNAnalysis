% This code finds the RDM for EEG filtered in some narrower bands of interest.
% 
% 
% @ June 2020 - SH

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
cd([MatlabRoot 'Data'])
load('RandomNetVariables')
num_shf = 100;

num_subj = 16;      % EEG var: Native speakers only
num_rep = 4;        % EEG var: number of repetitions (which will be assumed as session later in the RDM analysis)
num_trials = 100;   % EEG var
trial_length = 8.5; % EEG var: unit(sec)
%% Data Preparation %%
%%%%%%%%%%%%%%%%%%%%%%
eucRDMs_RandomNet_100shf = cell(num_layers,num_shf);
BaseName = 'AllStimuliforExp2WithAllEmbeddingsRandomNetwork000';
for ii = 0:num_shf-1
    FileName = [BaseName(1:end-length(num2str(ii))) num2str(ii)];
    cd([MatlabRoot 'Data/random_networks'])
    load(FileName)
    data = {myEmbeddingsLayer1{:};myEmbeddingsLayer2{:};myEmbeddingsLayer3{:};...
        myEmbeddingsRNN{:};myEmbeddingsLayer5{:};myEmbeddingsLayer6{:}};
    % Zeropadding
    num_neurons = zeros(num_layers,num_stim);
    RandomNetResponse = cell(1,num_layers);
    for stim = 1:num_stim
        m = max(numSamples2) - numSamples2(1,stim);
        for lay = 1:num_layers
            num_neurons(lay,stim) = size(data{lay,stim},2);
            data{lay,stim} = [data{lay,stim}; zeros(m,num_neurons(lay,stim))];
            % Matrices of Network Responses
            RandomNetResponse{lay}(:,stim) = reshape(data{lay,stim}',[],1);
        end
    end
    clear data
    for lay = 1:num_layers
        eucRDMs_RandomNet_100shf{lay,ii+1} = rsa.rdm.squareRDMs(pdist(RandomNetResponse{lay}','euclidean'));
    end
    clear RandomNetResponse
    disp(['***** Net ' num2str(ii+1) ' done! *****'])
end
%% save
cd([MatlabRoot 'Result/RSA/Network_RDMs/RandomNet'])
save('eucRDMs_RandomNet_100shf','eucRDMs_RandomNet_100shf')

% % % Delete below: they're correct, but I remembered that RDMs for EEG
% subjects are already saved
% % % % %% EEG RDMs (separated by subjects)
% % % % cd('/Volumes/EEGlab_SH/Saeedeh/ShwetasData/SortedEEGdat')
% % % % ch = [25,20,11,4,124,21,12,5,119,13,6,113]; %(ch can be a vector of channels)
% % % % num_chnl = length(ch);
% % % % eucRDMs_EEGsubjects = cell(1,num_subj-1);
% % % % cte = 0;
% % % % for subj = [1,3:num_subj]
% % % %     cte = cte+1;
% % % %     load(['eeg_' num2str(subj)])
% % % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %     EEGresponse = zeros(2125*num_chnl, num_stim, num_rep);
% % % %     for rep = 1:num_rep %~Session
% % % %         for stim = 1:num_stim  %~Condition
% % % %             % Order of trials: 1st stim was repeated 4 times, then 2nd stim
% % % %             % for 4 times, and so on to the 25th stim. -> 100 trials in total
% % % %             EEGresponse(:,stim,rep) = reshape(EEGdat(ch,:,4*(stim-1)+rep)',[],1);  %  data-points (of all selected channels) x num_stim
% % % %         end
% % % %     end
% % % %     % I first average EEG responses over repetitions to reduce the
% % % %     % noise and then find the RDM
% % % %     eucRDMs_EEGsubjects{cte} = rsa.rdm.squareRDMs(pdist(mean(EEGresponse(:,:,rep),3)','euclidean'));
% % % %     clear EEGdat
% % % %     disp(['**** Subj ' num2str(subj) ' done *****'])
% % % % end
% % % % %% save
% % % % cd([MatlabRoot 'Result/RSA/EEG_RDMs/RDMs'])
% % % % save('eucRDMs_EEGsubjects','eucRDMs_EEGsubjects')