% This function is to load concatenated audio files and return the stimuli
% files only, and also how to randomize them.
% It also applies the ramp-up and -down at the begining and the end of the
% stimuli, based on the fs.
%
% INPUT:        - DataPath: the path to the chosenSentences that contains
%                 the concatenated stimuli in the variable CnctSound
%               - kSpeakers: number of speakers (~ utterances)
%               - kRepetition: number of repetitions.
%               - fs: sampling rate of the stimuli
%               - rampON: if 1, then normalize the stimuli, and smooth the
%               beggining and end of it with a 10ms ramp
%
% OUTPUTS:      - stim: a column-wise cell array of stimuli, each of which
%               is a column vector
%               - rnd_spk_rep: randomization indices.
%
% @Feb 2020 - SH and SB


function [stim,rnd_spk_rep,keptSpks] = prep_stim(DataPath,kSpeakers,kRepetition,fs,rampON)

% Load the path to the files
load(DataPath)
% Reducing the number of speakers to 8
keptSpks = [keptSpks(1:fix(kSpeakers/2)); keptSpks(6:5+ceil(kSpeakers/2))];

% The raw signal
if fs == 16e3
    stim(:, 1) = CnctSound(keptSpks);
elseif fs == 44100
    stim(:, 1) = CnctSoundNew(keptSpks);
else
    error('Sampling rate is not correct')
end

rng('shuffle');
rnd_spk_rep = zeros(kRepetition,kSpeakers);
% Random permutation of the speakers
for ii = 1:kRepetition
    rnd_spk_rep(ii,:) = randperm(kSpeakers); % rows: repetitions, columns: speakers
end
%%%%%%%%%%%%%%%%%%% Ramp up and down %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if rampON == 1
    % A 10 ms onset/offset ramp
    kSamplesInRamp = floor(fs * 0.01);
    % A 10 ms onset ramp
    onRamp = linspace(0, 1, kSamplesInRamp);
    % A 10 ms offset ramp
    offRamp = linspace(1, 0, kSamplesInRamp);

    % The normalization of the stimuli
    for i = 1:kSpeakers
        % Scale it between [-1 +1]
        stim{i} = (stim{i} - mean(stim{i})) ./ abs(max(stim{i}));
        % Adding a ramp at each end to avoid transients
        stim{i}(1:kSamplesInRamp, 1) = stim{i}(1:kSamplesInRamp, 1) .* onRamp';
        stim{i}(length(stim{i}) - kSamplesInRamp + 1: end, 1) = stim{i}(length(stim{i}) - kSamplesInRamp + 1: end, 1) .* offRamp';
    end
end
return
