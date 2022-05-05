function [Xpaired,Ypaired,Xsingle,Ysingle,assign] = gePartialData(View1Fea,View2Fea,pairPortion)
% generate partial data
% 
% Input:
%       View1Fea    -each row is a sample in View1
%       View2Fea    -each row is a sample in View2
%       pairPortion	-a scalar in (0,1) = 1-POR
% Output:
%       Xpaired     -View1's samples that have View2
%       Ypaired     -View2's samples that have View1
%       Xsingle     -View1's samples that do not have View2
%       Ysingle     -View2's samples that do not have View1
%       assign      -a nSmp*2 vector with each row means: 1-exist,0-missing


[nSmp, ~] = size(View1Fea);
nPaired = fix(nSmp*pairPortion);  % number of samples with complete views
nSingleView1 = ceil(0.5*(nSmp-nPaired));
%nSingleView2 = nSmp-nPaired-nSingleView1;

RANDnSmp = randperm(nSmp);
paired = sort(RANDnSmp(1:nPaired),'ascend');
singleView1 = sort(RANDnSmp(nPaired+1:nSingleView1+nPaired),'ascend');
singleView2 = sort(RANDnSmp(nSingleView1+nPaired+1:end),'ascend');

Xpaired = View1Fea(paired,:);   
Ypaired = View2Fea(paired,:);
Xsingle = View1Fea(singleView1,:);
Ysingle = View2Fea(singleView2,:);

assign = zeros(nSmp,2);
assign(paired,:) = 1;
assign(singleView1,1) = 1;
assign(singleView2,2) = 1;
