function [Label, F] = SpectralClustering(Z,S,para)
% Spectral Clustering
% Input:
%       Z        -instance-to-anchor similarity matrix
%       S        -instance-to-instance similarity matrix
%       para     -some parameters as follows
%       para.type-type of used spectral clustering
%                 'regular': regular spectral clustering (default)
%                 'fastSVD': fast version by SVD on A=Z*Lambda^(-1/2)
%                 'fastEIG': fast version by eigen decomposition on R=A'*A
%       para.c   -number of clusters
%       para.k   -number of nearest anchors for computing similarities
% Output:
%       Label   -cluster labels by spectral clustering


if strcmpi(para.type, 'fastSVD')
    A = Z*diag(1./sqrt(sum(Z,1)));
    [F,~,~] = svd(A);
    if size(F,2) > para.c
        F = F(:,1:para.c);
    end
elseif strcmpi(para.type, 'fastEIG')
    A = Z*diag(1./sqrt(sum(Z,1)));
    [B, Theta] = eigs(A'*A, para.c, 'LM'); % LM: Largest Magnitude
    F = A*B*Theta^(-0.5);
else
    S = 0.5*(S+S'); % symmetric part
    S = full(max(S,S')); % just to guarantee symmetry, can comment out
    L = diag(sum(S,2)) - S;
    L = full(max(L,L')); % just to guarantee symmetry, can comment out
    [F, ~] = eigs(L + eps*eye(size(L,1)), para.c, 'SM'); % SM: Smallest Magnitude
end
% F = normcols(F')';
Label = litekmeans((normcols(F'))',para.c,'Replicates',20,'MaxIter',1e3);
% Users can adopt 'litekmeans.m', which is a fast version.
Label = Label(:);