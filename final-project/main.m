% Main function for Bag of words classification

% Authors: Riaan Zoetmulder & Minh Ngo

% Configuring libsvm
%   addpath <path to the libsvm folder>/matlab/
%
% Configuring vlfeat
%   run('<path to the vlfeat folder>/toolbox/vl_setup')
%

function main()
    %% Experiment parameters
    type = 'gray';
    kp_or_dense = 'dense';
    %% number of images for clustering
    nimages = 400;
    
    num_centroids = 400;
    
    step_size = 8;
    bin_size = 4;

    extract_sift(type, kp_or_dense, step_size, bin_size);
    
    train_files = file_list('./Caltech4/ImageSets/train.txt');
    
    %% Shuffle files
    train_files = train_files(randperm(length(train_files)));
    
    [~, ~, ~] = mkdir('./Caltech4/FeatureData', type);
    [~, ~, ~] = mkdir(strcat('./Caltech4/FeatureData/', type), kp_or_dense);
    dump_dir = strcat('./Caltech4/FeatureData/', type, '/', kp_or_dense, '/');
    if strcmp(kp_or_dense, 'dense') == 1
        [~, ~, ~] = mkdir(dump_dir, num2str(step_size));
        [~, ~, ~] = mkdir(strcat(dump_dir, num2str(step_size)), num2str(bin_size));
        dump_dir = strcat(dump_dir, num2str(step_size), '/', num2str(bin_size), '/');
    end
    
    centroid_file = strcat(dump_dir, 'kmeans_centroids.mat');
    if exist(centroid_file, 'file') == 0
        %% Taking first nimages_cluseting images for clustering
        train_files_for_clustering = train_files(1:nimages);

        stacked_features = double(stack_descriptors(train_files_for_clustering,...
                                                    type, kp_or_dense, step_size, bin_size));
    
        display('Computing centroids');
        [centroids, ~] = k_means(stacked_features, num_centroids);
        %centroids
        save(centroid_file, 'centroids');
    else
        display('Loading centroids');
        load(centroid_file);
    end
    
    histogram_file = strcat(dump_dir, 'histograms.mat');
    if exist(histogram_file, 'file') == 0
        train_labels = extract_labels(train_files);
        train_histograms = quantize_files(train_files, centroids, type,...
                                          kp_or_dense, step_size, bin_size);

        save(histogram_file, 'train_histograms', 'train_labels');
    else
        load(histogram_file);
    end
    
    train_mean = mean(train_histograms, 2);
    train_std = std(train_histograms, 0, 2);
    
    train_histograms = scale(train_histograms, train_mean, train_std);

    [svm1, svm2, svm3, svm4] = train_SVMs(train_labels, train_histograms');
    
    %% Computes training accuracy
    display('Computing training accuracy');
    [predicted_class, tp, tn, fp, fn, precision, recall, accuracy, ap, map, ranks] =...
        predict_SVMs(svm1, svm2, svm3, svm4, train_labels, train_histograms');

    %% Testing
    test_files = file_list('./Caltech4/ImageSets/test.txt');
    test_labels = extract_labels(test_files);
    test_histograms = quantize_files(test_files, centroids, type, kp_or_dense, step_size, bin_size);
    test_histograms = scale(test_histograms, train_mean, train_std);
    
    display('Computing testing accuracy');
    [predicted_class, tp, tn, fp, fn, precision, recall, accuracy, ap, map, ranks] =...
        predict_SVMs(svm1, svm2, svm3, svm4, test_labels, test_histograms');
    
    correct_predictions = predicted_class == test_labels;
    accuracy = length(predicted_class(correct_predictions)) / length(predicted_class);
    
    display(sprintf('Final accuracy: %.3f', accuracy));
end