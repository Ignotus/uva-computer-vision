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
    type = 'RGB';
    kp_or_dense = 'kp';
    %% number of images for clustering
    nimages = 400;
    
    num_centroids = 200;

    extract_sift(type, kp_or_dense);
    
    train_files = file_list('./Caltech4/ImageSets/train.txt');
    
    %% Shuffle files
    train_files = train_files(randperm(length(train_files)));
    %% Taking first nimages_cluseting images for clustering
    train_files_for_clustering = train_files(1:nimages);

    stacked_features = double(stack_descriptors(train_files_for_clustering, type, kp_or_dense));
    
    if exist('./Caltech4/FeatureData/kmeans_centroids.mat', 'file') == 0
        display('Computing centroids');
        [centroids, ~] = k_means(stacked_features, num_centroids);
        save('./Caltech4/FeatureData/kmeans_centroids.mat', 'centroids');
    else
        display('Loading centroids');
        load('./Caltech4/FeatureData/kmeans_centroids.mat');
    end
    
    if exist('./Caltech4/FeatureData/histograms.mat', 'file') == 0
        train_labels = extract_labels(train_files);
        train_histograms = quantize_files(train_files, centroids, type, kp_or_dense);

        save('./Caltech4/FeatureData/histograms.mat', 'train_histograms', 'train_labels');
    else
        load('./Caltech4/FeatureData/histograms.mat');
    end
    
    train_mean = mean(train_histograms, 2);
    train_std = std(train_histograms, 0, 2);
    
    train_histograms = scale(train_histograms, train_mean, train_std);
    
    [svm1, svm2, svm3, svm4] = train_SVMs(train_labels, train_histograms');
    
    %% Computes training accuracy
    display('Computing training accuracy');
    predict_SVMs(svm1, svm2, svm3, svm4, train_labels, train_histograms');
    
    %% Testing
    test_files = file_list('./Caltech4/ImageSets/test.txt');
    test_labels = extract_labels(test_files);
    test_histograms = quantize_files(test_files, centroids, type, kp_or_dense);
    test_histograms = scale(test_histograms, train_mean, train_std);
    
    display('Computing testing accuracy');
    predict_SVMs(svm1, svm2, svm3, svm4, test_labels, test_histograms');
end