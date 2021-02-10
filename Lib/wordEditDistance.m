% This function returns the edit distance for two words. This takes in two
% cell arrays where each cell contains one word
function editDistance = wordEditDistance(source,target)

% Initilize variables
sourceLength=length(source);
targetLength=length(target);
x=0:targetLength;
y=zeros(1,targetLength);

%Calculate the editDistance
for i=1:sourceLength
    y(1)=i;
    for j=1:targetLength
        % If the words don't match, set the cost to 1, if they do match set
        % it to 0
        cost=(~strcmp(source{i},target{j}));
        y(j+1)= min([
            y(j)+1
            x(j+1)+1
            x(j)+cost
            ]);
    end
    [x,y]=deal(y,x);
end

% Retrieve the edit distance and normalize it
editDistance=x(targetLength+1);
editDistance=editDistance/length(target);

end

