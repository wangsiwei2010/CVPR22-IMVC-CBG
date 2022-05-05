function [Z,S] = getSim(Xpaired,Ypaired,Xsingle,Ysingle,para) 
% 1) construct anchor graphs in an unsupervised manner
% 2) compute the fused similarity matrix
% 
% Input: (each row is an instance)
%       Xpaired -View1's instances that have View2 
%       Ypaired -View2's instances that have View1
%       Xsingle -View1's instances that do not have View2
%       Ysingle -View2's instances that do not have View1
%       para    -some parameters as follows 
%       para.k  -number of neighbors for construct a neighbor-graph
% Output:
%       Z       -instance-to-anchor similarity matrix
%       S       -instance-to-instance similarity matrix


%% Settings
[nPaired, ~] = size(Xpaired);
[nSingle1, ~] = size(Xsingle);
[nSingle2, ~] = size(Ysingle);
nSmp = nPaired + nSingle1 + nSingle2;

if ~exist('para', 'var')
    k = nSmp;
else
    k = para.k;
end

if k < 1  || k > nSmp
    error('Parameter k is error!');
end  

% k = nSmp;

%% Run
Z1 = withinSim([Xpaired;Xsingle],Xpaired,k); 
Z2 = withinSim([Ypaired;Ysingle],Ypaired,k); 
Z = [0.5*(Z1(1:nPaired,:)+Z2(1:nPaired,:)); ...
    Z1(nPaired+1:end,:); Z2(nPaired+1:end,:)];
S = Z*diag(1./sum(Z,1))*Z';
S = full(max(S,S')); % guarantee symmetry
end


%% compute within-view similarity
function [Z] = withinSim(allSmp,anchor,k) 
% Input:
%   allSmp -each row is a sample (n-by-d)
%   anchor -selected from allSmp (m-by-d)
%   k      -number of neighbors
% Output:
%   Z      -instance-to-anchor similarity matrix (n-by-m)
[n, ~] = size(allSmp);
[m, ~] = size(anchor);
Dist = EuDist2(allSmp,anchor,0); % Euclidean distance.^2
sigma = 4*mean(mean(Dist));% optional:4*mean(mean(Dist)); % optional: sigma = 10
[~, idx] = sort(Dist,2); % sort each row ascend
idx = idx(:,1:k); % default: self-connected
G = sparse(repmat([1:n]',[k,1]),idx(:),ones(numel(idx),1),n,m);
%%% the i_th row of matrix G stores the information of the  
%%% i_th sample's k neighbors. (1: is a neighbor, 0: is not)
Z = (exp(-Dist/sigma)).*G; % Gaussian kernel weight
% Z= exp(-Dist/sigma);
Z = bsxfun(@rdivide,Z,sum(Z,2));
Z(Z<1e-10) = 0;
end