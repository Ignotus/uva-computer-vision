function folder_name = feature_folder_name(folder, type, kp_or_dense, step_size, bin_size)
    if strcmp(kp_or_dense, 'dense') == 1
        folder_name = strcat('./Caltech4/FeatureData/', folder, '/', type,...
                             '/', kp_or_dense, '/', int2str(step_size), '/', int2str(bin_size), '/');
    else
        folder_name = strcat('./Caltech4/FeatureData/', folder, '/', type,...
                             '/', kp_or_dense, '/');
    end
end