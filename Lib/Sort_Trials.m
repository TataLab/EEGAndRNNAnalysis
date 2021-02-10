% Trials saved in these two variables trialed_data.trial
% and trialed_data.time are based on the order presented to the participant.
% This function sorts trials based on the randomized indices.
%
% INPUT:   - trial_cfg: ft_definetrial output which contains information of
%          trials.
%          - trialed_data: ft_preprocessing output which contains recorded 
%           data in each trial and the corresponding timestamps.
%          - Optional: numSpk, numRep, (=10 by default)
%
% OUTPUT:  - sortTrials and sortTime: each is a cell array of the size numSpk x numRepeatition
%
% 
% @ Jan 2020 - SH

function [sortTrials,sortTime] = Sort_Trials(trial_cfg,trialed_data,varargin)
numSpk = 10;
numRep = 10;
assignopts(who, varargin);

sortTrials = cell(numSpk,numRep);
sortTime = cell(numSpk,1);
spk = trial_cfg.trl(:,5);
rep = trial_cfg.trl(:,6);

for ii = 1:100
    sortTrials{spk(ii),rep(ii)} = trialed_data.trial{1,ii};
    % sortTime is the same for all repetitions of the same speaker
    % So, it is ok to over write it
    sortTime{spk(ii),1} = trialed_data.time{1,ii};  
end
    
return