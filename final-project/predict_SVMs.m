% Make predictions

function [prediction, ap, map] = predict_SVMs(svm1, svm2, svm3, svm4, target, data)
    [predict_label, ~, prob_estimates1] = predict_class(svm1, target, data, 1);
    [predict_label, ~, prob_estimates2] = predict_class(svm2, target, data, 2);
    [predict_label, ~, prob_estimates3] = predict_class(svm3, target, data, 3);
    [predict_label, ~, prob_estimates4] = predict_class(svm4, target, data, 4);
    
    class_probs = horzcat(prob_estimates1, prob_estimates2, prob_estimates3, prob_estimates4);
    
    [ap, map] = mean_average_precision(target, class_probs);
    display(sprintf('Mean average precision = %.3f', map));
    [~, prediction] = max(class_probs, [], 2);
end

function [predict_label, accuracy, prob_estimates] = predict_class(svm, target, data, class)
    display('________________');
    target = reshape(double(target == class), size(target));
    [predict_label, accuracy, prob_estimates] = svmpredict(target, data, svm, '-b 1');
    analyze_predictions(predict_label, target);
    prob_estimates = prob_estimates(:,1) .* predict_label;
end

function analyze_predictions(predict_label, target)
    true_positives = 0;
    true_negatives = 0;
    
    false_positives = 0;
    false_negatives = 0;
    
    for i=1:length(predict_label)
        if target(i) == 1
            if predict_label(i) == 1
                true_positives = true_positives + 1;
            else
                false_negatives = false_negatives + 1;
            end
        else
            if predict_label(i) == 0
                true_negatives = true_negatives + 1;
            else
                false_negatives = false_negatives + 1;
            end
        end
    end
    
    precision = true_positives / (true_positives + false_positives);
    recall = true_positives / (true_positives + false_negatives);
    accuracy = (true_positives + true_negatives) /...
        (true_positives + false_positives + true_negatives + false_negatives);
    
    display(sprintf('True positives = %d', true_positives));
    display(sprintf('True negatives = %d', true_negatives));
    display(sprintf('False positives = %d', false_positives));
    display(sprintf('False negatives = %d', false_negatives));
    display(sprintf('Precision = %.3f', precision));
    display(sprintf('Recall = %.3f', recall));
    display(sprintf('Accuracy = %.3f', accuracy));
end

function [ap, map] = mean_average_precision(target, class_probs)
    ap = zeros(4, 1);
    position = (1:length(target))';
    for class=1:4
        class_prob = class_probs(:,class);
        class_target = reshape(double(target == class), size(target));
        stat = [class_prob class_target];

        [~, I] = sort(class_prob, 'descend');
        ranking = stat(I,:);

        class_target = ranking(:,2);

        ap(class) = 1 / sum(class_target) *...
            sum(class_target .* cumsum(class_target) ./ position);
    end

    map = mean(ap);
end