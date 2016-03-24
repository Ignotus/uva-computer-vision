% Main function for Bag of words classification

% Authors: Riaan Zoetmulder & Minh Ngo

function main()
    %% Experiment parameters
    type = 'gray';
    kp_or_dense = 'kp';
    %% number of images for clustering
    nimages = 10;
    %extract_sift(type, kp_or_dense);
    
    train_files = file_list('./Caltech4/ImageSets/train.txt');
    
    %% Shuffle files
    train_files = train_files(randperm(length(train_files)));
    %% Taking first nimages_cluseting images for clustering
    train_files = train_files(1:nimages);

    stacked_features = stack_descriptors(train_files, type, kp_or_dense);
    size(stacked_features)
end