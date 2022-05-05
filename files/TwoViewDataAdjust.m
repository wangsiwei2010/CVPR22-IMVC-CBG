function [Xpaired,Ypaired,Xsingle,Ysingle,NEWlabel] = ...
    TwoViewDataAdjust(View1Fea,View2Fea,ind,label)
% Adjust partial two-view data from the original three-view manner
% (remove the instances that miss two views, i.e. only exist in View3)
% 
% Input:
%       View1Fea    -each row is an instance in View1
%       View2Fea    -each row is an instance in View2
%       ind         -indicate the instance is missing(=0) or not(=1)
%       label       -cluster label vector (ground truth)
% Output:
%       Xpaired     -View1's instances that have View2
%       Ypaired     -View2's instances that have View1
%       Xsingle     -View1's instances that do not have View2
%       Ysingle     -View2's instances that do not have View1
%       NEWlabel    -adjusted cluster label vector (ground truth)


Xpaired = View1Fea(find(sum(ind,2)==2),:);
Ypaired = View2Fea(find(sum(ind,2)==2),:);
Xsingle = View1Fea(find(ind(:,2)==0 & ind(:,1)~=0),:);
Ysingle = View2Fea(find(ind(:,1)==0 & ind(:,2)~=0),:);
NEWlabel = label([find(sum(ind,2)==2); ...
    find(ind(:,2)==0 & ind(:,1)~=0); ...
    find(ind(:,1)==0 & ind(:,2)~=0)]);