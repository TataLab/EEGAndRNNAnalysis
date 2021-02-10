% This function receives the ip address for the netstation computer and
% connects to it if the flag is 1.
% 
% @Feb 2020 - SH and SB

function Connect2NetStation(flag,nsHost)

if isempty(flag)
    eeg = 0;
else
    eeg = flag;
end

if(eeg)
    % Creating a connection to that host
    NetStation('Connect', nsHost);
    % Synchronizing the clock
    NetStation('Synchronize');
    % Start recording the session
    NetStation('StartRecording');
end
return