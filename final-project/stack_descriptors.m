function stacked_features = stack_descriptors(files, type, kp_or_dense, step_size)
    stacked_features = 0;

    for file=files
        [folder, file_name] = extract_filemeta(file);
        output_file = descriptor_file_name(folder, type, kp_or_dense, step_size, file_name);
        
        load(output_file{1});
        if stacked_features == 0
            stacked_features = features;
        else
            stacked_features = [stacked_features features];
        end
    end
end