function extract_sift(type, kp_or_dense)
    [~, ~, ~] = mkdir('./Caltech4/FeatureData', 'airplanes_train');
    [~, ~, ~] = mkdir('./Caltech4/FeatureData', 'cars_train');
    [~, ~, ~] = mkdir('./Caltech4/FeatureData', 'faces_train');
    [~, ~, ~] = mkdir('./Caltech4/FeatureData', 'motorbikes_train');
    
    [~, ~, ~] = mkdir('./Caltech4/FeatureData', 'airplanes_test');
    [~, ~, ~] = mkdir('./Caltech4/FeatureData', 'cars_test');
    [~, ~, ~] = mkdir('./Caltech4/FeatureData', 'faces_test');
    [~, ~, ~] = mkdir('./Caltech4/FeatureData', 'motorbikes_test');
    
    extract_features(type, kp_or_dense, './Caltech4/ImageSets/train.txt');
    extract_features(type, kp_or_dense, './Caltech4/ImageSets/test.txt');
end

function extract_features(type, kp_or_dense, file)
    for tline=file_list(file)
        [folder, file_name] = extract_filemeta(tline);
        
        output_file = descriptor_file_name(folder, type, kp_or_dense, file_name);
        if exist(output_file{1}, 'file') == 0
            features = feature_extraction(strcat('./Caltech4/ImageData/', tline{1}, '.jpg'), type, kp_or_dense);
            save(output_file{1}, 'features');
        end
    end
end