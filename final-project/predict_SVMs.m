% Make predictions

function [prediction, class_probs, m_average_precision] = predict_SVMs(svm1, svm2, svm3, svm4, target, data)
    [predict_label, accuracy, prob_estimates1] = predict_class(svm1, target, data, 1);
    [predict_label, accuracy, prob_estimates2] = predict_class(svm2, target, data, 2);
    [predict_label, accuracy, prob_estimates3] = predict_class(svm3, target, data, 3);
    [predict_label, accuracy, prob_estimates4] = predict_class(svm4, target, data, 4);
    
    class_probs = horzcat(prob_estimates1, prob_estimates2, prob_estimates3, prob_estimates4);
    
    m_average_precision = mean_average_precision(target, class_probs)
    [~, prediction] = max(class_probs, [], 2);
end

function [predict_label, accuracy, prob_estimates] = predict_class(svm, target, data, class)
    target = reshape(double(target == class), size(target));
    [predict_label, accuracy, prob_estimates] = svmpredict(target, data, svm, '-b 1');
    prob_estimates = prob_estimates(:,1) .* predict_label;
end

function map = mean_average_precision(target, class_probs)
    map = zeros(4, 1);
    position = (1:length(target))';
    for class=1:4
        class_prob = class_probs(:,class);
        class_target = reshape(double(target == class), size(target));
        stat = [class_prob class_target];

        [~, I] = sort(class_prob, 'descend');
        ranking = stat(I,:);

        class_target = ranking(:,2);

        map(class) = 1 / sum(class_target) *...
            sum(class_target .* cumsum(class_target) ./ position);
    end

    map = mean(map);
end