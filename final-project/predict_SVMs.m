% Make predictions

function prediction = predict_SVMs(svm1, svm2, svm3, svm4, target, data)
    
    target_1 = target;
    target_1(target_1 > 1) = 0;
    [predict_label, accuracy, dec_values] = svmpredict(target_1, data, svm1, '-b 0');
    class_probs = dec_values(:,1);
    
    target_2 = target;
    target_2(target_2 > 2 ) = 0;
    target_2(target_2 < 2) = 0;
    target_2(target_2 == 2) = 1;
    [predict_label, accuracy, dec_values] = svmpredict(target_2, data, svm2, '-b 0');
    class_probs = horzcat(class_probs, dec_values(:,1));
    
    target_3 = target;
    target_3(target_3 > 3) = 0;
    target_3(target_3 < 3) = 0;
    target_3(target_3 == 3) = 1;
    [predict_label, accuracy, dec_values] = svmpredict(target_3, data, svm3, '-b 0');
    class_probs = horzcat(class_probs, dec_values(:,1));
    
    target_4 = target;
    target_4(target_4 < 4) = 0;
    target_4(target_4 == 4) = 1;
    [predict_label, accuracy, dec_values] = svmpredict(target_4, data, svm4, '-b 0');
    class_probs = horzcat(class_probs, dec_values(:,1));

    [~, prediction] = max(class_probs');
end