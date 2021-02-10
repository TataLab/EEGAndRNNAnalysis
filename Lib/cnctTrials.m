% This function takes the 10x10 array of trials (spk x rep)
% and concatenate all the Trials in a big 3D matrix of 70 electrode x
% samplePoints of all spk's in each repetition x repetition
% 
%  INPUT: - either sortTrials or lp_sortTrials which is a 10x10 cell array
%         - fs: sampling rate of datapoints in lp_sortTrials and lp_sortTime
% 
% OUTPUT: - TrialsMat: a matrix of concatenated trials
% order:
% [ trial1(spk1,rep1), trial2(spk2,rep1), ..., trial3(spk10,rep1)
%   trial1(spk1,rep2), trial2(spk2,rep2), ..., trial3(spk10,rep2)
% ...
%   trial1(spk1,rep10),trial2(spk2,rep10), ..., trial3(spk10,rep10)]
% 
%         - TimeMat: a matrix of concatenated timepoints corresponding to each epoch of TrialsMat 
%         assuming the first time point of each epoch is 0. unit(sec)
%         - Ev_sample: stores the sample number of events 
%         events are defined as: start of the trial(including the
%         baseline), triger, duration of stimuli
%         - Ev_time: stores the timepoint of events. unit(msec)
% 
% 
% @Feb 2020 - SH


function [TrialsMat, TimeMat, Ev_sample, Ev_time, Ep_info] = cnctTrials(lp_sortTrials,varargin)
fs = 500;
PreStim = 2;  % unit(sec) pre-stimulus time for baseline
assignopts(who, varargin);
% variables
numSpk = size(lp_sortTrials,1);
numRep = size(lp_sortTrials,2);

% Calculatingb size of TrialsMat
numElect = size(lp_sortTrials{1,1},1);
ncol = cellfun(@length, lp_sortTrials);  % number of columns per repetition
numDataPoints = sum(ncol(:,1));
% TrialsMat = zeros(numElect, numDataPoints);
TrialsMat = zeros(numElect, numDataPoints, numRep);
% storing trials in TrialsMat
for rep = 1:numRep
%     TrialsMat(:,sum(ncol)*(rep-1)+1:sum(ncol)*rep) = cat(2,lp_sortTrials{:,rep});
    TrialsMat(:,:,rep) = cat(2,lp_sortTrials{:,rep});
end
% corresponding timepoint
TimeMat = (0:numDataPoints-1)./fs; % unit(sec)
% Making array of events
numEv = numSpk; % per repetition
temp = [0;ncol(:,1)];  
[Ev_sample,Ev_time] = deal(zeros(numEv,3));

for ev = 1:numEv
    Ev_sample(ev,1) = sum(temp(1:ev))+1; % Start samplepoint of the event(including PreStim)
end
Ev_sample(:,2) = Ev_sample(:,1)+fs*PreStim;  % Start samplepoint of the triger
Ev_sample(:,3) = temp(2:end) - fs*PreStim;   % Duration of the stimulus in sample points

Ev_time(:,1) = TimeMat(Ev_sample(:,1)); % start timepoint of the event(including PreStim)
% Ev_time(:,1) = (Ev_sample(:,1)-1)./fs; % Equivalent to the previous line
Ev_time(:,2) = TimeMat(Ev_sample(:,2)); % start timepoint of the triger
Ev_time(:,3) = (Ev_sample(:,3)-1)./fs;  % Duration of the stimulus in sec

% number of rows correspond to the number of epochs (~numRep) 
% number of columns correspond to the number of events per epoch (3*numSpk)
% Trial_st1 stim_latency duration
Ep_info = repmat(reshape(Ev_time', 1, []),numRep,1);
return