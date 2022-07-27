clear;
clc;

addpath(genpath('./'));

datadir='./datasets/';
dataname = {'NGs'};

numdata = length(dataname); % number of the test datasets
numname = {'_Per0.1', '_Per0.2', '_Per0.3', '_Per0.4','_Per0.5', '_Per0.6', '_Per0.7', '_Per0.8', '_Per0.9'};

for idata = 1:length(dataname)
    ResBest = zeros(9, 8);
    ResStd = zeros(9, 8);
    for dataIndex = 1:1:9

        datafile = [datadir, cell2mat(dataname(idata)), cell2mat(numname(dataIndex)), '.mat'];
        load(datafile);
        %data preparation...
        gt = truelabel{1};
        cls_num = length(unique(gt));
        k= cls_num;
        tic;
        [X1, ind] = findindex(data, index);
        
        time1 = toc;
        maxAcc = 0;
        TempAnchor = [k];
        
        ACC = zeros(length(TempAnchor));
        NMI = zeros(length(TempAnchor));
        Purity = zeros(length(TempAnchor));
        idx = 1;
        for LambdaIndex2 = 1 : length(TempAnchor)
            numanchor = TempAnchor(LambdaIndex2);
            disp([char(dataname(idata)), char(numname(dataIndex)),  '-numanchor=', num2str(numanchor)]);
            tic;
            [F,V,A,W,Z,iter,obj,alpha,ts] = missingalgo_qp(X1,gt,k,numanchor,ind); % X,Y,lambda,d,numanchor

            F = F ./ repmat(sqrt(sum(F .^ 2, 2)), 1, k);

            time2 = toc;
            stream = RandStream.getGlobalStream;
            reset(stream);
            MAXiter = 1000; % Maximum number of iterations for KMeans
            REPlic = 20; % Number of replications for KMeans
            tic;
            for rep = 1 : 20
                pY = kmeans(F, cls_num, 'maxiter', MAXiter, 'replicates', REPlic, 'emptyaction', 'singleton');
                res(rep, : ) = Clustering8Measure(gt, pY);
            end
            time3 = toc;
            runtime(idx) = time1 + time2 + time3/20;
            disp(['runtime:', num2str(runtime(idx))])
            idx = idx + 1;
            tempResBest(dataIndex, : ) = mean(res);
            tempResStd(dataIndex, : ) = std(res);
            for tempIndex = 1 : 8
                if tempResBest(dataIndex, tempIndex) > ResBest(dataIndex, tempIndex)
                    if tempIndex == 1
                        newZ = Z;
                        newF = F;
                    end
                    ResBest(dataIndex, tempIndex) = tempResBest(dataIndex, tempIndex);
                    ResStd(dataIndex, tempIndex) = tempResStd(dataIndex, tempIndex);
                end
            end
        end
        aRuntime = mean(runtime);
        PResBest = ResBest(dataIndex, :);
        PResStd = ResStd(dataIndex, :);
    end
end
