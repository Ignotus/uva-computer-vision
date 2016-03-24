function output_file = descriptor_file_name(folder, type, kp_or_dense, file_name)
    output_file = strcat('./Caltech4/FeatureData/', folder, '/', type, '_', kp_or_dense, '_', file_name, '.mat');
end