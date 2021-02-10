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
load('TrainedNetVariables')

num_subj = 16;      % EEG var: Native speakers only
num_rep = 4;        % EEG var: number of repetitions (which will be assumed as session later in the RDM analysis)
num_trials = 100;   % EEG var
trial_length = 8.5; % EEG var: unit(sec)

%% Filter Design %%
%%%%%%%%%%%%%%%%%%%
BW = 2; % narrwo-band filter for 2Hz BW
cte1 = 1; Hd = cell(1,10); 
Hd{1} = LPF_Gaussian_fs250_order100(2);
Fpass = zeros(2,10); % stores the filter limits
for ii = 2:2:18
    cte1 = cte1+1;
    Fpass(:,cte1) = [ii;ii+BW];
%     Hd{cte} = BP_filter_fs250_order300(ii-1,ii,ii+BW,ii+BW+1);
Hd{cte1} = BPF_Gaussian_fs250_order100(ii,ii+BW);
end
%% Data Preparation %%
%%%%%%%%%%%%%%%%%%%%%%
cd('/Volumes/EEGlab_SH/Saeedeh/ShwetasData/SortedEEGdat')
ch = [25,20,11,4,124,21,12,5,119,13,6,113]; %(ch can be a vector of channels)
num_chnl = length(ch);
[subjectRDMs_corr,subjectRDMs_euclidean] = deal(cell(1,10));
[subjectRDMs_corr{:},subjectRDMs_euclidean{:}] = deal(zeros(num_stim,num_stim,num_subj-1));
cte = 0;
for subj = [1,3:num_subj]
    cte = cte+1;
    load(['eeg_' num2str(subj)])
    for flt = 1:10 %we use 10 different narrow-band filter
        %%%%%%%%%%% filter EEG_dat %%%%%%%%%%%%%
        flt_EEGdat = zeros(num_chnl,2125,num_trials);
        for tr = 1:num_trials
            for c = 1:num_chnl
                flt_EEGdat(c,:,tr) = filtfilt(Hd{flt},1,squeeze(EEGdat(ch(c),:,tr)));
            end
        end
        %Visualizing the original and filtered signal
%         [f,y,s_amp,d_amp] = FrequencyDomain(250,squeeze(EEGdat(25,:,1)),1);
%         L = length(squeeze(flt_EEGdat(1,:,1)));
%         t =(0:L-1)/250;
%         subplot(3,1,1);hold on;plot(t,flt_EEGdat(1,:,1),'r');
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [RDM_temp_corr,RDM_temp_euclidean] = deal(zeros(num_stim,num_stim));
        EEGresponse = zeros(2125*num_chnl, num_stim, num_rep);
        for rep = 1:num_rep %~Session
            for stim = 1:num_stim  %~Condition
                % Order of trials: 1st stim was repeated 4 times, then 2nd stim
                % for 4 times, and so on to the 25th stim. -> 100 trials in total
                EEGresponse(:,stim,rep) = reshape(flt_EEGdat(:,:,4*(stim-1)+rep)',[],1);  %  data-points (of all selected channels) x num_stim
            end
            RDM_temp_corr = RDM_temp_corr+rsa.rdm.squareRDMs(pdist(EEGresponse(:,:,rep)','correlation'));
            RDM_temp_euclidean = RDM_temp_euclidean+rsa.rdm.squareRDMs(pdist(EEGresponse(:,:,rep)','euclidean'));
        end
        subjectRDMs_corr{flt}(:,:,cte) = RDM_temp_corr./num_rep; %average RDMs over the repetisions
        subjectRDMs_euclidean{flt}(:,:,cte) = RDM_temp_euclidean./num_rep; %average RDMs over the repetisions
    end
    clear EEGdat
    disp(['**** Subj ' num2str(subj) ' done *****'])
end
%% save
cd([MatlabRoot 'Result/RSA/RDM_narrowBandEEG'])
save('RDM_narrowBandEEG','subjectRDMs_corr','subjectRDMs_euclidean')