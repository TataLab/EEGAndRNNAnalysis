% This code finds the frequency representation of data and looks at the
% power spectral density as well;
% Data is the output of recurrecnt layer of the network which Lukas gave me.
%
%
% @Jan 2020 - SH

clc; clear; close all;
MatlabRoot = '/Users/eeglab/Desktop/Matlab';
addpath(genpath(MatlabRoot));
load([MatlabRoot '/Result/StimInfo'])
load('/Users/eeglab/Desktop/Matlab/Result/StimInfo.mat')

cd([MatlabRoot '/SaeedehLukas']);
load('lstm_output')
load('shuffled_word_lstm_output.mat')
load('shuffled_phn_lstm_output.mat')

%% Preparing variables
data = {stim_lstm{:};shuffled_word_lstm{:};shuffled_phn_lstm{:}};
num_spk = 10;
num_neurons = size(stim_lstm{1},2);
% Computing sampling rate:
original_fs = 16e3;   % This is the sampling rate of the input not the output of the network!
% but the new sampling rate should be computed based on the number of
% samples in the inpt layer and the output layer.
numSamples1 = sum([StimInfoStruct.numSample]);
[fs,numSamples2] = deal(zeros(1,num_spk));
for spk = 1:num_spk
    numSamples2(spk) = size(stim_lstm{spk},1);
    fs(spk) = original_fs*numSamples2(spk)/numSamples1(spk);
end
%% fft
[f,y,s_amp,d_amp] = deal(cell(1,3)); % origina, word shuffled, and phoneme shuffled
for ii = 1:3  % original, word-shuffled, and phoneme-shuffled 
    for spk = 1
        for nron = 1
            x = data{ii,spk}(:,1)';
            [f{ii},y{ii},s_amp{ii},d_amp{ii}] = FrequencyDomain(fs(spk),x,1);
        end
    end
end
