function [UU,V,A,W,Z,iter,obj,alpha,ts] = missingalgo_qp(X,Y,d,numanchor,ind)
% m      : the number of anchor. the size of Z is m*n.
% lambda : the hyper-parameter of regularization term.

% X      : n*di

%% initialize
maxIter = 50 ; % the number of iterations

m = numanchor;
numclass = length(unique(Y));
numview = length(X);
numsample = size(Y,1);

W = cell(numview,1);            % di * d
A = zeros(d,m);         % d  * m
Z = zeros(m,numsample); % m  * n


missingindex = constructA(ind);
for i = 1:numview
   %%X{i} = mapstd(X{i}',0,1); % turn into d*n
   di = size(X{i},1); 
   W{i} = zeros(di,d);
end
Z(:,1:m) = eye(m);


alpha = ones(1,numview)/numview;
opt.disp = 0;

flag = 1;
iter = 0;
%%
while flag
    iter = iter + 1;
    
    %% optimize W_i
    parfor iv=1:numview
        C = X{iv}*Z'*A';      
        [U,~,V] = svd(C,'econ');
        W{iv} = U*V';
    end

    %% optimize A2
    sumAlpha = 0;
    part1 = 0;
    for ia = 1:numview
        al2 = alpha(ia)^2;
        sumAlpha = sumAlpha + al2;
        part1 = part1 + al2 * W{ia}' * X{ia} * Z';
    end
    [Unew,~,Vnew] = svd(part1,'econ');
    A = Unew*Vnew';
    
    %% optimize Z
    C1 = 0;
    C2 = 0;
    for a=1:numview
        C1 = C1 + alpha(a)^2*ind(:,a)'; 
        C2 = C2 + alpha(a)^2 * A'* W{a}'*X{a};
    end
    
    for ii=1:numsample
        idx = 1:numanchor;
        ut = C2(idx,ii)./C1(ii);
        Z(idx,ii) = EProjSimplex_new(ut');
    end
    
    [UU,~,V]=svd(Z','econ');
    ts{iter} = UU(:,1:numclass);

    %% optimize alpha
    M = zeros(numview,1);
    for iv = 1:numview
        M(iv) = norm( X{iv} - W{iv} * A * (Z.*repmat(missingindex{iv},m,1)),'fro');
    end
    Mfra = M.^-1;
    Q = 1/sum(Mfra);
    alpha = Q*Mfra;

    %%
    term1 = 0;
    for iv = 1:numview
        term1 = term1 + alpha(iv)^2 * norm(X{iv} - W{iv} * A * (Z.*repmat(missingindex{iv},m,1)),'fro')^2;
    end
    obj(iter) = term1;
    
    
    if (iter>1) && (abs((obj(iter-1)-obj(iter))/(obj(iter-1)))<1e-3 || iter>maxIter || obj(iter) < 1e-10)
        [UU,~,V]=svd(Z','econ');
        UU = UU(:,1:numclass);
        flag = 0;
    end
end
         
         
    
