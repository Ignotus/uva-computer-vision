% Make predictions

function class_probs = predict_SVMs(svm1, svm2, svm3, svm4, target, data)

    [predict_label, accuracy, dec_values] = svmpredict(target', data', svm1, '-b 1');
    class_probs = dec_values(:,1);
    
    [predict_label, accuracy, dec_values] = svmpredict(target', data', svm2, '-b 1');
    class_probs= horzcat(class_probs, dec_values(:,1));
    
    [predict_label, accuracy, dec_values] = svmpredict(target', data', svm3, '-b 1');
    class_probs= horzcat(class_probs, dec_values(:,1));
    
    [predict_label, accuracy, dec_values] = svmpredict(target', data', svm4, '-b 1');
    class_probs= horzcat(class_probs, dec_values(:,1));
    
    class_probs

end