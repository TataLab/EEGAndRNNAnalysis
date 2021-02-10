n = 0.1*randn(size(x));
x1 = sin(x)+n;
x2 = cos(x)+2*n;
% d = (x1-x2).^2;
% d = d/numel(x);
% d = sqrt(sum(d))
% 
% corr(x1',x2')
d1 = pdist([x1;x2],'euclidean');
d2 = pdist([x1;x2],'correlation');
[d1,d2]