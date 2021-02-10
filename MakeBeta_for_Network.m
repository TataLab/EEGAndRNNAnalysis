% This code reads te network output data, makes and saves the beta
% images and betaCorrespondence
% 
% 
% @ May 2020 - SH

clc; clear;
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
cd([MatlabRoot 'Data'])
% Load one of the below
Net = input('Which Network you are ineterested in(1 for TrianedNet, 2 for RandomNet, 3 for PhonemeNet)?'); % 1 for TrianedNet, 2 for RandomNet, 3 for PhonemeNet
if Net == 1
    load('AllStimuliforExp2WithAllEmbeddings')  % For the trained network
elseif Net == 2
    load('AllStimuliforExp2WithAllEmbeddingsRandomNetwork') % For the network that is not trained.
elseif Net ==3
    load('AllStimuliforExp2WithAllEmbeddingsPhonemeNetwork') % For the phonemely-trained network
end
%% Preparing model variables
data = {myEmbeddingsLayer1{:};myEmbeddingsLayer2{:};myEmbeddingsLayer3{:};...
    myEmbeddingsRNN{:};myEmbeddingsLayer5{:};myEmbeddingsLayer6{:}};
LayerNames = {'1','2','3','RNN','5','6'};
num_stim = size(data,2);
num_layers = size(data,1);

% Computing sampling rate:
original_fs = 16e3;   % This is the sampling rate of the input not the output of the network!
% but the new sampling rate should be computed based on the number of
% samples in the inpt layer and the output layer.
[fs,numSamples1,numSamples2,ln_data] = deal(zeros(1,num_stim));  % number of samples remain the same between the layers
for stim = 1:num_stim
    numSamples1(1,stim) = length(mySoundData{stim});
    numSamples2(1,stim) = size(data{1,stim},1);
    fs(1,stim) = original_fs*numSamples2(1,stim)/numSamples1(1,stim);
end
%% save variables
cd([MatlabRoot 'Data'])
saveFileNames = {'TrainedNet','RandomNet','PhonemeNet'};
save([saveFileNames{Net} 'Variables'],'LayerNames','num_stim','num_layers',...
    'original_fs','fs','numSamples1','numSamples2')
%% Zeropadding
% The length of stimuli are in the range of 5.5 to 6.47 sec, so the length
% of the network output signals are also different.
% The EEG data, however, are from 0.7sec before starting the trigger 
% to the 7.8sec after, which returns 8.5sec of EEG data.
%%%%%%%%%
% Maybe I should zeropad my Embeddings accordingly ?????
%%%%%%%%%
% If I don't zeropad them to have the same length, we're gonna have error
% in rsa.fmri.fMRIDataPreparation (line 119), as the brainVectors are not
% from the same size
num_neurons = zeros(num_layers,num_stim);
for stim = 1:num_stim
    m = max(numSamples2) - numSamples2(1,stim);
    for lay = 1:num_layers
        num_neurons(lay,stim) = size(data{lay,stim},2);
        data{lay,stim} = [data{lay,stim}; zeros(m,num_neurons(lay,stim))];
    end
end
%% Making Betas
FolderNames = {'TrainedNet','RandomNet','PhonemeNet'};
for lay = 1:num_layers
    cd([MatlabRoot 'Result/RSA/Network_Betas/' FolderNames{Net}])
    mkdir(['Net_Lay' LayerNames{lay} '_Betas'])
    cd([MatlabRoot 'Result/RSA/Network_Betas/' FolderNames{Net} '/Net_Lay' LayerNames{lay} '_Betas'])
    for stim = 1:num_stim
        betaImage = data{lay,stim};  % datapoints x num_chnl
        save(['Beta_stim' num2str(stim)],'betaImage')
    end
    disp(['Beta for layer ' LayerNames{lay} ' is saved ...............']);
end
%% Make betaCorrespondence
%{
%  betaCorrespondence store the name of the beta files
for stim = 1:num_stim
    betaCorrespondence(1,stim).identifier = ['Beta_stim' num2str(stim) '.mat'];
end
cd([MatlabRoot 'Result/RSA/Network_Betas'])
save('betaCorrespondence','betaCorrespondence')
%}
