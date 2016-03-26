function output_file = descriptor_file_name(folder, type, kp_or_dense, step_size, file_name)
    output_file = feature_folder_name(folder, type, kp_or_dense, step_size);
    output_file = strcat(output_file, file_name, '.mat');
end