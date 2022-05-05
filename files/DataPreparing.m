function [X1, ind] = DataPreparing(data, index)
% X{k} = Xc{k}*O1{k} + X2{k}*O2{k}
% [D, N] = size(X{k}), [D, N_c] = size(Xc{k}), [D, N_i] = size(X2{k}),
% [N_c, N] = size(O1{k}), [N_i, N] = size(O2{k})

K = length(data); %numOfView
N = size(data{1}, 2); %numOfSample
X1 = cell(K,1); %the complete parts
O1 = cell(K, 1);
Xc = cell(K,1);
ind = zeros(N, K);
for k = 1:K
    W1 = ones(N, 1);
    W1(index{k}, 1) = 0;
    ind_1 = W1 == 1;
    W2 = eye(N);
    W2(ind_1, :) = [];
    O1{k} = W2;
    data{k} = double(data{k});
    data{k}(isnan(data{k})) = 0;
    Xc{k} = data{k} * O1{k}';
%     [Xc{k}] = NormalizeData(Xc{k});
    Xc{k} = normcols(Xc{k});
    X1{k} = Xc{k} * O1{k};
    ind(index{k}, k) = 1;
end
end