close all
clear all
clc
addpath(genpath('./files'));
warning('off');


%% Settings and pre-process
load('Data_3Sources.mat')
% Each row of V1/V2/V3 is an instance. All-zero rows denote missing 
% The total number of instances is 416 for 3Sources dataset.
%%% V1: BBC, feature dimension is 3560
%%% V2: Guardian, feature dimension is 3631
%%% V3: Reuters, feature dimension is 3068
%%% ind: indicate the instance is missing(=0) or not(=1)
%%% label: cluster label vector (ground truth)
V1 = (normcols(V1'))'; %each instance is normalized to unit l2-norm
V2 = (normcols(V2'))'; %each instance is normalized to unit l2-norm
V3 = (normcols(V3'))'; %each instance is normalized to unit l2-norm
para.c = length(unique(label)); % K: number of clusters
para.k = 12; % m: number of nearest anchors


% %% subset 1: BBC-Guardian
% fprintf('\n----- subset 1: BBC-Guardian -----');
% [Xpaired,Ypaired,Xsingle,Ysingle,NEWlabel] = ...
%     TwoViewDataAdjust(V1,V2,ind(:,[1 2]),label);
% scLabel = APMC_2views(Xpaired,Ypaired,Xsingle,Ysingle,para);
% [ACC,NMI] = EvaluateClustering(scLabel,NEWlabel);
% fprintf('\nACC(%%) is %.02f%% ', ACC*100);
% fprintf('\nNMI(%%) is %.02f%% \n', NMI*100);
% 
% 
%% subset 2: BBC-Reuters
fprintf('\n----- subset 2: BBC-Reuters -----');
[Xpaired,Ypaired,Xsingle,Ysingle,NEWlabel] = ...
    TwoViewDataAdjust(V1,V3,ind(:,[1 3]),label);
scLabel = APMC_2views(Xpaired,Ypaired,Xsingle,Ysingle,para);
[ACC,NMI] = EvaluateClustering(scLabel,NEWlabel);
fprintf('\nACC(%%) is %.02f%% ', ACC*100);
fprintf('\nNMI(%%) is %.02f%% \n', NMI*100);
% 
% 
% %% subset 3: Guardian-Reuters
% fprintf('\n----- subset 3: Guardian-Reuters -----');
% [Xpaired,Ypaired,Xsingle,Ysingle,NEWlabel] = ...
%     TwoViewDataAdjust(V2,V3,ind(:,[2 3]),label);
% scLabel = APMC_2views(Xpaired,Ypaired,Xsingle,Ysingle,para);
% [ACC,NMI] = EvaluateClustering(scLabel,NEWlabel);
% fprintf('\nACC(%%) is %.02f%% ', ACC*100);
% fprintf('\nNMI(%%) is %.02f%% \n', NMI*100);


%% Utilize all three views
% fprintf('\n----- utilize all three views -----');
% [scLabel,NEWlabel] = APMC_3views(V1,V2,V3,ind,label,para);
% [ACC,NMI] = EvaluateClustering(scLabel,NEWlabel);
% fprintf('\nACC(%%) is %.02f%% ', ACC*100);
% fprintf('\nNMI(%%) is %.02f%% \n', NMI*100);