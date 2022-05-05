function scLabel = APMC_2views(Xpaired,Ypaired,Xsingle,Ysingle,para) 
% 'APMC_2views.m' implements Algorithm 1 in our paper
% 
% Input: (each row is an instance)
%       Xpaired -View1's instances that have View2 
%       Ypaired -View2's instances that have View1
%       Xsingle -View1's instances that do not have View2
%       Ysingle -View2's instances that do not have View1
%       para    -some parameters as follows
%       para.c  -number of clusters
%       para.k  -number of nearest anchors for computing similarities
% Output:
%       scLabel -cluster label vector by spectral clustering


%% Step 1 & 2
[Z, S] = getSim(Xpaired,Ypaired,Xsingle,Ysingle,para);

%% Step 3
para.type = 'fastEIG'; % 3 types: 'regular','fastSVD','fastEIG'
scLabel = SpectralClustering(Z,S,para);