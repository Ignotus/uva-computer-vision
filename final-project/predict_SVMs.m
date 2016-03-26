% Make predictions

function [prediction, class_probs] = predict_SVMs(svm1, svm2, svm3, svm4, target, data)
    [predict_label, accuracy, prob_estimates] = predict_class(svm1, target, data, 1);
    class_probs = prob_estimates;
    
    [predict_label, accuracy, prob_estimates] = predict_class(svm2, target, data, 2);
    class_probs = horzcat(class_probs, prob_estimates);
    
    [predict_label, accuracy, prob_estimates] = predict_class(svm3, target, data, 3);
    class_probs = horzcat(class_probs, prob_estimates);
    
    [predict_label, accuracy, prob_estimates] = predict_class(svm4, target, data, 4);
    class_probs = horzcat(class_probs, prob_estimates);

    %predict_label == uint8(target == 4)
    [~, prediction] = max(class_probs, [], 2);
end

function [predict_label, accuracy, prob_estimates] = predict_class(svm, target, data, class)
    target = reshape(double(target == class), size(target));
    [predict_label, accuracy, prob_estimates] = svmpredict(target, data, svm, '-b 1');
    prob_estimates = prob_estimates(:,1) .* predict_label;
end
