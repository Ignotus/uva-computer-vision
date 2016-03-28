% Support Vector Machine Training function

function [svm1, svm2, svm3, svm4, tf] = train_SVMs(target, data)
    % Train the first SVM
    [svm1, t1, f1] = train_class(target, data, 1);
    [svm2, t2, f2] = train_class(target, data, 2);
    [svm3, t3, f3] = train_class(target, data, 3);
    [svm4, t4, f4] = train_class(target, data, 4);
    
    tf = [t1 f1; t2 f2; t3 f3; t4 f4];
end

function [svm, t, f] = train_class(target, data, class)
    target = reshape(double(target == class), size(target));
    t = sum(target);
    f = length(target) - t;
    svm = svmtrain(target, data, '-s 0 -t 2 -b 1 -q -c 3');
end
