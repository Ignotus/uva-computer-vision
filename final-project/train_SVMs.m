% Support Vector Machine Training function

function [svm1, svm2, svm3, svm4] = train_SVMs(target, data)
    % Train the first SVM
    svm1 = train_class(target, data, 1);
    svm2 = train_class(target, data, 2);
    svm3 = train_class(target, data, 3);
    svm4 = train_class(target, data, 4);
end

function svm = train_class(target, data, class)
    target = reshape(double(target == class), size(target));
    svm = svmtrain(target, data, '-s 0 -t 2 -b 1 -q');
end
