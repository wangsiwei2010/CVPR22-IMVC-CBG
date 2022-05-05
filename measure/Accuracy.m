function ACC = Accuracy(C,gt)
 C = bestMap(gt,C);
 ACC = length(find(gt == C))/length(gt);
end