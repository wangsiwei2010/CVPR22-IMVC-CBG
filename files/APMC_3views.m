function [Stotal, NEWlabel] = APMC_3views(V1,V2,V3,ind,label,para)
% 'APMC_3views.m' implements clustering on partial three-view data 
% 
% Input: (each row is an instance)
%       V1      -View1's instances (all-zero rows denote missing) 
%       V2      -View2's instances (all-zero rows denote missing)
%       V3      -View3's instances (all-zero rows denote missing)
%       ind     -indicate the instance is missing(=0) or not(=1)
%       label   -cluster label vector (ground truth)
%       para    -some parameters as follows
%       para.c  -number of clusters
%       para.k  -number of nearest anchors for computing similarities
% Output:
%       scLabel -cluster label vector by spectral clustering
%       c-adjusted cluster label vector (ground truth)


%% Settings & Compute the number of different-type instances
idx = zeros(size(ind,1),7);
idx(find(sum(ind,2)==3),1)=1; % nc
idx(find(sum(ind(:,1:2),2)==2 & sum(ind,2)==2),2)=1; % n12
idx(find(sum(ind(:,[1,3]),2)==2 & sum(ind,2)==2),3)=1; % n13
idx(find(sum(ind(:,2:3),2)==2 & sum(ind,2)==2),4)=1; % n23
idx(find(ind(:,1)==1 & sum(ind,2)==1),5)=1; % n1
idx(find(ind(:,2)==1 & sum(ind,2)==1),6)=1; % n2
idx(find(ind(:,3)==1 & sum(ind,2)==1),7)=1; % n3
dlen = zeros(7,1); % store the values of nc, n12, n13, n23, n1, n2, n3
for i = 1:7
    dlen(i) = length(find(idx(:,i)==1));
end
NEWlabel = label([find(idx(:,1)==1);find(idx(:,2)==1);...
    find(idx(:,3)==1);find(idx(:,4)==1);find(idx(:,5)==1);...
    find(idx(:,6)==1);find(idx(:,7)==1)]); % new label after adjusting


%% Derive the equivalent two-view similarity matrices
% The following is subcase 1: 1-2
Xpaired = V1([find(idx(:,1)==1);find(idx(:,2)==1)],:);
Ypaired = V2([find(idx(:,1)==1);find(idx(:,2)==1)],:);
Xsingle = V1([find(idx(:,3)==1);find(idx(:,5)==1)],:);
Ysingle = V2([find(idx(:,4)==1);find(idx(:,6)==1)],:);
[~,S1] = getSim(Xpaired,Ypaired,Xsingle,Ysingle,para);   
dord1 = zeros(size(ind,1),7); % the order is nc, n12, n13, n23, n1, n2
pnt = 1;
for j = [1 2 3 5 4 6]
    dord1(pnt:pnt-1+dlen(j),j) = 1;
    pnt = pnt + dlen(j);
end
% The following is subcase 2: 1-3
Xpaired = V1([find(idx(:,1)==1);find(idx(:,3)==1)],:);
Ypaired = V3([find(idx(:,1)==1);find(idx(:,3)==1)],:);
Xsingle = V1([find(idx(:,2)==1);find(idx(:,5)==1)],:);
Ysingle = V3([find(idx(:,4)==1);find(idx(:,7)==1)],:);
[~,S2] = getSim(Xpaired,Ypaired,Xsingle,Ysingle,para);
dord2 = zeros(size(ind,1),7); % the order is nc, n13, n12, n2, n1, n3
pnt = 1;
for j = [1 3 2 5 4 7]
    dord2(pnt:pnt-1+dlen(j),j) = 1;
    pnt = pnt + dlen(j);
end
% The following is subcase 3: 2-3
Xpaired = V2([find(idx(:,1)==1);find(idx(:,4)==1)],:);
Ypaired = V3([find(idx(:,1)==1);find(idx(:,4)==1)],:);
Xsingle = V2([find(idx(:,2)==1);find(idx(:,6)==1)],:);
Ysingle = V3([find(idx(:,3)==1);find(idx(:,7)==1)],:);
[~,S3] = getSim(Xpaired,Ypaired,Xsingle,Ysingle,para);
dord3 = zeros(size(ind,1),7); % the order is nc, n23, n12, n2, n13, n3
pnt = 1;
for j = [1 4 2 6 3 7]
    dord3(pnt:pnt-1+dlen(j),j) = 1;
    pnt = pnt + dlen(j);
end


%% Derive aligned similarity matrices of subcases and get Stotal
% Stotal: total similarity matrix
% pnt_x, pnt_y: pointers for rows and columns
% t: the weight matrix for averaging 
Stotal = zeros(size(ind,1));
t = zeros(size(ind,1));
pnt_x = 1;
for i = 1:7
    pnt_y = 1;
    for j = 1:7
        if i<5 
            if j<5
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S1(find(dord1(:,i)==1),find(dord1(:,j)==1)) ...
                    + S2(find(dord2(:,i)==1),find(dord2(:,j)==1)) ...
                    + S3(find(dord3(:,i)==1),find(dord3(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 3;
            elseif j == 5
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S1(find(dord1(:,i)==1),find(dord1(:,j)==1)) ...
                    + S2(find(dord2(:,i)==1),find(dord2(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 2;
            elseif j == 6
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S1(find(dord1(:,i)==1),find(dord1(:,j)==1)) ...
                    + S3(find(dord3(:,i)==1),find(dord3(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 2;
            elseif j == 7
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S2(find(dord2(:,i)==1),find(dord2(:,j)==1)) ...
                    + S3(find(dord3(:,i)==1),find(dord3(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 2;
            end
        elseif i == 5
            if j < 6
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S1(find(dord1(:,i)==1),find(dord1(:,j)==1)) ...
                    + S2(find(dord2(:,i)==1),find(dord2(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 2;
            elseif j == 6
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S1(find(dord1(:,i)==1),find(dord1(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 1;
            elseif j == 7
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S2(find(dord2(:,i)==1),find(dord2(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 1;
            end
        elseif i == 6
            if j ~= 5 && j~= 7
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S1(find(dord1(:,i)==1),find(dord1(:,j)==1)) ...
                    + S3(find(dord3(:,i)==1),find(dord3(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 2;
            elseif j == 5
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S1(find(dord1(:,i)==1),find(dord1(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 1;
            elseif j == 7
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S3(find(dord3(:,i)==1),find(dord3(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 1;
            end
        elseif i == 7
            if j ~= 5 && j~= 6
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S2(find(dord2(:,i)==1),find(dord2(:,j)==1)) ...
                    + S3(find(dord3(:,i)==1),find(dord3(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 2;
            elseif j == 5
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S2(find(dord2(:,i)==1),find(dord2(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 1;
            elseif j == 6
                Stotal(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = ...
                    S3(find(dord3(:,i)==1),find(dord3(:,j)==1));
                t(pnt_x:pnt_x-1+dlen(i),pnt_y:pnt_y-1+dlen(j)) = 1;
            end
        end
        pnt_y = pnt_y + dlen(j);
    end
    pnt_x = pnt_x + dlen(i);
end
Stotal = Stotal./t;
% para.type = 'regular';
% scLabel = SpectralClustering([],Stotal,para);