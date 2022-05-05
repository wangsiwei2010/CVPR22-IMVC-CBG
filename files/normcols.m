function matout = normcols(matin)
% Normalize each column of 'matin' to have unit l2-norm.
% Input:
%       matin   -a matrix
% Output:
%       matout  -a matrix (l2-norm of each column is 1)

l2norms = sqrt(sum(matin.^2,1));
l2norms(l2norms==0) = eps;
matout = bsxfun(@rdivide,matin,l2norms);