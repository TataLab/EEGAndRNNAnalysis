% This function returns the percent of words a response sentence is off by
% normalized by the number of words in the actual sentence along with the
% normalized word edit distance
% It takes in two sentences and works with them

function normalizedValues=editDistance(response,target)
% Turn strings into words in arrays
target=splitSentence(target);
response=splitSentence(response);

% Calculate the normalized number of words off
wordsOff=length(response)-length(target);
wordsOff=wordsOff/length(target);

% Calculate the word edit distance and normalize it
WED=wordEditDistance(response,target);

% Return the values
normalizedValues=[wordsOff WED];
return;