function extract_sift(type, kp_or_dense)
    classes = ['airplanes' 'cars' 'faces' 'motorbikes'];
    for class=classes
        [~, ~, ~] = mkdir('./Caltech4/FeatureData', strcat('airplanes', '_train'));
        [~, ~, ~] = mkdir('./Caltech4/FeatureData', strcat('airplanes', '_test'));
    end
    
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