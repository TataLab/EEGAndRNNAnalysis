% This function takes in a string and then returns it as an array, each
% cell containing one work in order with punctuation removed and all
% characters in lower case
% Shout to Haley and Saeedeh for writing most of this
function split=splitSentence(base)

% Copy the string to avoid any weird things involving data manipulation
modified=base;

% Remove punctuation and lower all characters
match = ['?',"'",'!', '.', ","];
modified = erase(modified, match);
modified = lower(modified);

% Split sentence into words and make that into an array
split = strsplit(modified);

return