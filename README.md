# Introduction 

CVPR22-IMVC-CBG

This repo is a MATLAB implementaion of **Highly-efficient Incomplete Large-scale Multi-view Clustering with Consensus Bipartite Graph** in CVPR2022

# Understanding

We think introducing anchor learning into IMVC can benefit large-scale tasks. For better understading, we strongly recommend reading [Notes on implementing large-scale IMVC with anchor graphs](https://www.researchgate.net/publication/359940353_Notes_on_implementing_large-scale_IMVC_with_anchor_graphs).

# Algorithm steps
Step1: Generating partial incomplete multi-view datasets with incompelte ratio from 0.1 to 0.9

Using the 'Incomplete/randomlyGeneratePartialData.m' provided by Professor Chang Tang in ['High-Order Correlation Preserved Incomplete Multi-View Subspace Clustering'](https://github.com/ChangTang/HCP-IMSC) published in IEEE TIP2022.

Step2: run run.m

# Time
To further speed up the algorithm, we can use parfor in Matlab for Parallel Computing while the first time run will cost some time. For large-scale tasks, it is time-saving.

# Parallel work code
[Scalable Partial Multi-view Clustering with Consistent Anchor Graph](https://github.com/wangsiwei2010/SPMVC-CAG)

We found initialation important for large-scale IMVC tasks. We are trying to accomplish a deep neural network for new work. Advice is welcome.

# Given example 
In 'Incomplete' files, we provide the incomplete datasets for Caltech101-7/20/BDGP.

# Randomness
The results may be slightly different with the $k$-means. (We report 20 runs and report the avearge)

# Implementation details
Provided key functions for future work:

## EprojSimplex.m: 
funtion to sovle anchor graph $\mathbf{Z}$, provided by [Weiran Wang](https://home.ttic.edu/~wwang5/) -- [Projection onto the capped simplex](https://home.ttic.edu/~wwang5/papers/projcapped.pdf)

## other optimization: 
In machine learning and computer vision community, the used optimization is called Orthogonal Procrustes Analysis which has been well studied in  literature.

-------
Notice:
There is no need for constructing matrix A $\in \mathbb{R}^{n \times n_i}$ ($n_i$ donotes the number of existing samples) as mentioned in the paper.(constructA.m) Only findindex.m is used in large-scale incomplete multi-view clustering.


# Connection
Thanks. Any problem can contact Siwei Wang(wangsiwei13@nudt.edu.cn).
