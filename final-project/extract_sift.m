% Extracts SIFT descriptors for each image from the training and testing
% sets
function extract_sift(type, kp_or_dense, step_size, bin_size)
    classes = ['airplanes' 'cars' 'faces' 'motorbikes'];
    for class=classes
        [~, ~, ~] = mkdir('./Caltech4/FeatureData', strcat('airplanes', '_train'));
        [~, ~, ~] = mkdir('./Caltech4/FeatureData', strcat('airplanes', '_test'));
    end
    
    extract_features(type, kp_or_dense, step_size, bin_size, './Caltech4/ImageSets/train.txt');
    extract_features(type, kp_or_dense, step_size, bin_size, './Caltech4/ImageSets/test.txt');
end

function extract_features(type, kp_or_dense, step_size, bin_size, file)
    for tline=file_list(file)
        [folder, file_name] = extract_filemeta(tline);
        
        root_folder = strcat('./Caltech4/FeatureData/', folder, '/');
        root_folder = root_folder{1};
        [~, ~, ~] = mkdir(root_folder, type);
        [~, ~, ~] = mkdir(strcat(root_folder, type), kp_or_dense);
        if strcmp(kp_or_dense, 'dense') == 1
            [~, ~, ~] = mkdir(strcat(root_folder, type, '/', kp_or_dense), num2str(step_size));
            [~, ~, ~] = mkdir(strcat(root_folder, type, '/', kp_or_dense, '/', num2str(step_size), '/'), num2str(bin_size));
        end
        
        output_file = descriptor_file_name(folder, type, kp_or_dense, step_size, bin_size, file_name);
        if exist(output_file{1}, 'file') == 0
            output_file{1}
            features = feature_extraction(strcat('./Caltech4/ImageData/', tline{1}, '.jpg'), type, kp_or_dense, step_size, bin_size);
            display(size(features));
            save(output_file{1}, 'features');
        end
    end
end