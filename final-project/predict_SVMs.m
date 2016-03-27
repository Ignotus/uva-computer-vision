% Make predictions

function [prediction, tp, tn, fp, fn, precision, recall, accuracy, ap, map, ranks] = predict_SVMs(svm1, svm2, svm3, svm4, target, data)
    
    [~, tp1, tn1, fp1, fn1, precision1, recall1, accuracy1, prob_estimates1] = predict_class(svm1, target, data, 1);
    [~, tp2, tn2, fp2, fn2, precision2, recall2, accuracy2, prob_estimates2] = predict_class(svm2, target, data, 2);
    [~, tp3, tn3, fp3, fn3, precision3, recall3, accuracy3, prob_estimates3] = predict_class(svm3, target, data, 3);
    [~, tp4, tn4, fp4, fn4, precision4, recall4, accuracy4, prob_estimates4] = predict_class(svm4, target, data, 4);
    
    tp = [tp1 tp2 tp3 tp4];
    tn = [tn1 tn2 tn3 tn4];
    fp = [fp1 fp2 fp3 fp4];
    fn = [fn1 fn2 fn3 fn4];
    precision = [precision1 precision2 precision3 precision4];
    recall = [recall1 recall2 recall3 recall4];
    accuracy = [accuracy1 accuracy2 accuracy3 accuracy4];
    
    class_probs = horzcat(prob_estimates1, prob_estimates2, prob_estimates3, prob_estimates4);
    
    [ap, map, ranks] = mean_average_precision(target, class_probs);
    display(sprintf('Mean average precision = %.3f', map));
    [~, prediction] = max(class_probs, [], 2);
end

function [predict_label, tp, tn, fp, fn, precision, recall, accuracy, prob_estimates] = predict_class(svm, target, data, class)
    display('________________');
    target = reshape(double(target == class), size(target));
    [predict_label, accuracy, prob_estimates] = svmpredict(target, data, svm, '-b 1');
    [tp, tn, fp, fn, precision, recall] = analyze_predictions(predict_label, target);
    prob_estimates = prob_estimates(:,1) .* predict_label;
end

function [tp, tn, fp, fn, precision, recall] = analyze_predictions(predict_label, target)
    tp = 0;
    tn = 0;
    
    fp = 0;
    fn = 0;
    
    for i=1:length(predict_label)
        if target(i) == 1
            if predict_label(i) == 1
                tp = tp + 1;
            else
                fn = fn + 1;
            end
        else
            if predict_label(i) == 0
                tp = tp + 1;
            else
                fn = fn + 1;
            end
        end
    end
    
    precision = tp / (tp + fp);
    recall = tp / (tp + fn);
    %accuracy = (tp + tn) / (tp + fp + tn + fn);
    
    display(sprintf('True positives = %d', tp));
    display(sprintf('True negatives = %d', tn));
    display(sprintf('False positives = %d', fp));
    display(sprintf('False negatives = %d', fn));
    display(sprintf('Precision = %.3f', precision));
    display(sprintf('Recall = %.3f', recall));
    %display(sprintf('Accuracy = %.3f', accuracy));
end

function [ap, map, indexes] = mean_average_precision(target, class_probs)
    ap = zeros(4, 1);
    indexes = zeros(4, length(target));
    position = (1:length(target))';
    for class=1:4
        class_prob = class_probs(:,class);
        class_target = reshape(double(target == class), size(target));
        stat = [class_prob class_target];

        [~, indexes(class,:)] = sort(class_prob, 'descend');
        ranking = stat(indexes(class,:),:);

        class_target = ranking(:,2);

        ap(class) = 1 / sum(class_target) *...
            sum(class_target .* cumsum(class_target) ./ position);
    end

    map = mean(ap);
end