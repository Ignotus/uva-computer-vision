% Main function for Bag of words classification

% Authors: Riaan Zoetmulder & Minh Ngo

function main()
    %% Experiment parameters
    type = 'gray';
    kp_or_dense = 'kp';
    %% number of images for clustering
    nimages = 600;
    
    num_centroids = 800;

    extract_sift(type, kp_or_dense);
    
    train_files = file_list('./Caltech4/ImageSets/train.txt');
    
    %% Shuffle files
    train_files = train_files(randperm(length(train_files)));
    %% Taking first nimages_cluseting images for clustering
    train_files_for_clustering = train_files(1:nimages);

    stacked_features = double(stack_descriptors(train_files_for_clustering , type, kp_or_dense));
    size(stacked_features)
    
    if exist('./Caltech4/FeatureData/kmeans_centroids.mat', 'file') == 0
        display('Computing centroids');
        [centroids, ~] = k_means(stacked_features, num_centroids);
        save('./Caltech4/FeatureData/kmeans_centroids.mat', 'centroids');
    else
        display('Loading centroids');
        load('./Caltech4/FeatureData/kmeans_centroids.mat');
    end
    
    if exist('./Caltech4/FeatureData/histograms.mat', 'file') == 0
        labels = extract_labels(train_files);
        histograms = quantize_files(train_files, centroids, type, kp_or_dense);

        save('./Caltech4/FeatureData/histograms.mat', 'histograms', 'labels');
    else
        load('./Caltech4/FeatureData/histograms.mat');
    end

    [svm1, svm2, svm3, svm4] = train_SVMs(labels', histograms');
    
    %% Testing
    test_files = file_list('./Caltech4/ImageSets/test.txt');
    test_labels = extract_labels(test_files);
    test_histograms = quantize_files(test_files, centroids, type, kp_or_dense);
    predict_SVMs(svm1, svm2, svm3, svm4, test_labels,test_histograms);
end