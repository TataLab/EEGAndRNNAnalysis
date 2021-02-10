% This functoin takes the participant information
% INPUTS:     - WhatInfo is a cell array of all the string variables that the examiner 
%               wants to knwo about the participant, such as: ID, Age, Sex, Mother Tongue
%               Example: WhatInfo = {'ID', 'Age', 'Sex', 'Mother Tongue'}
%
%
% @Feb 2020 - SH, SB

function participant = get_participant_info(WhatInfo)

% Output this error message in the events that the information was not
% entered in the form
errorMsg = 'The program terminated. Some or all information was not entered properly';
% Creating a participant form for ID, Age, Sex, Mother Tongue
participantInformation = cell(1,length(WhatInfo)+1);
for ii = 1:length(WhatInfo)
    participantInformation{ii} = ['Enter the participant''s ', WhatInfo{ii}, ' :'];
end
participantInformation{end} = 'Type 1 to connect to NetStation, otherwise 0 to skip the connection:';

% Form window title
dialogTitle = 'New Participant';
% The size of the input field
dimensions = [1 50];
% Placeholder for the form's input field
defInput = {'', '', '', '', ''};
% Storing the information in participant, and displaying the form
participant = inputdlg(participantInformation, dialogTitle, dimensions, defInput);

for i = 1:4
    if isempty(participant{i})
        error(errorMsg);
    end
end
return