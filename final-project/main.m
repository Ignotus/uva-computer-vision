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

    [svm1, svm2, svm3, svm4, tf] = train_SVMs(train_labels, train_histograms');
    
    %% Computes training accuracy
    display('Computing training accuracy');
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
    final_accuracy = length(predicted_class(correct_predictions)) / length(predicted_class);
    
    display(sprintf('Final accuracy: %.3f', final_accuracy));
    
    export_stats(ap, map, ranks,...
                 type, kp_or_dense, nimages, num_centroids, step_size, bin_size,...
                 tf);
end

function export_stats(ap, map, ranks,...
                      type, kp_or_dense, nimages_clustering, num_centroids, step_size, bin_size,...
                      tf)
    author1 = 'Riaan Zoetmulder';
    author2 = 'Minh Ngo';
    
    file_name = strcat('./results_', type, '_', kp_or_dense, '_',...
                       num2str(nimages_clustering), '_', num2str(num_centroids), '_', num2str(step_size),...
                       '_', num2str(bin_size), '_', num2str(now) , '.html');
    file_id = fopen(file_name, 'w');

    fprintf(file_id, ['<!DOCTYPE html>'...
                      '<html lang="en">'...
                      '  <head>'...
                      '    <meta charset="utf-8">'...
                      '    <title>Image list prediction</title>'...
                      '    <style type="text/css">img { width:200px; }</style>'...
                      '  </head>'...
                      '  <body>']);
                  
    fprintf(file_id, '<h2>%s, %s</h2>', author1, author2);
    fprintf(file_id, '<h1>Settings</h1>');
    
    fprintf(file_id, ['<table><tr><th>SIFT step size</th><td>%3d px</td></tr>'...
                      '<tr><th>SIFT block sizes</th><td>%3d pixels</td></tr>'...
                      '<tr><th>SIFT method</th><td>%s-%s-SIFT</td></tr>'...
                      '<tr><th>Vocabulary size</th><td>%3d words</td></tr>'...
                      '<tr><th>SVM training data 1st</th><td>%3d positive, %3d negative per class</td></tr>'...
                      '<tr><th>SVM training data 2nd</th><td>%3d positive, %3d negative per class</td></tr>'...
                      '<tr><th>SVM training data 3rd</th><td>%3d positive, %3d negative per class</td></tr>'...
                      '<tr><th>SVM training data 4th</th><td>%3d positive, %3d negative per class</td></tr>'...
                      '<tr><th>SVM kernel type</th><td>%s</td></tr></table>'],...
                  step_size,...
                  bin_size,...
                  type,...
                  kp_or_dense,...
                  num_centroids,...
                  tf(1, 1), tf(1, 2),...
                  tf(2, 1), tf(2, 2),...
                  tf(3, 1), tf(3, 2),...
                  tf(4, 1), tf(4, 2),...
                  'RBF');
              
    fprintf(file_id, ['<h1>Prediction lists (MAP: %.3f)</h1>'...
                      '<table>'...
                      '<thead>'...
                      '<tr>'...
                      '<th>Airplanes (AP: %.3f)</th>'...
                      '<th>Cars (AP: %.3f)</th>'...
                      '<th>Faces (AP: %.3f)</th>'...
                      '<th>Motorbikes (AP: %.3f)</th>'...
                      '</tr>'...
                      '</thead>'...
                      '<tbody>'],...
            map, ap(1), ap(2), ap(3), ap(4));
    
    test_files = file_list('./Caltech4/ImageSets/test.txt');
    
    for i=1:length(test_files)
        fprintf(file_id, ['<tr><td><img src="Caltech4/ImageData/%s.jpg" /></td>'...
                          '<td><img src="Caltech4/ImageData/%s.jpg" /></td>'...
                          '<td><img src="Caltech4/ImageData/%s.jpg" /></td>'...
                          '<td><img src="Caltech4/ImageData/%s.jpg" /></td></tr>'],...
                test_files{ranks(1, i)}, test_files{ranks(2, i)},...
                test_files{ranks(3, i)}, test_files{ranks(4, i)});
    end
    
    fprintf(file_id, '</tbody></table></body></html>');
    fclose(file_id);
end