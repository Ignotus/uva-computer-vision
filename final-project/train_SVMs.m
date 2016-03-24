% Support Vector Machine Training function

function [svm1, svm2, svm3, svm4] = train_SVMs(target, data)
    
    % Train the first SVM
    target_1 = target;
    target_1(target_1 > 1) = 0;
    svm1 = svmtrain(target_1, data, '-t 2 -b 1');
    
    % Train the second SVM
    target_2 = target;
    target_2(target_2 > 2 ) = 0;
    target_2(target_2 < 2) = 0;
    target_2(target_2 == 2) = 1;
    svm2 = svmtrain(target_2, data, '-t 2 -b 1');
    
    % Train the third SVM
    target_3 = target;
    target_3(target_3 > 3) = 0;
    target_3(target_3 < 3) = 0;
    target_3(target_3 == 3) = 1;
    svm3 = svmtrain(target_3, data, '-t 2 -b 1');
    
    % Train the fourth SVM
    target_4 = target;
    target_4(target_4 < 4) = 0;
    target_4(target_4 == 4) = 1;
    svm4 = svmtrain(target_4, data, '-t 2 -b 1');
    
end

