function h = quantize_files(files, centroids, type, kp_or_dense)
    h = zeros(length(centroids), length(files));
    for i = 1:length(files)
        file = files(i);
        [folder, file_name] = extract_filemeta(file);
        output_file = descriptor_file_name(folder, type, kp_or_dense, file_name);
        
        load(output_file{1});
        features = double(features);
        h(:, i) = quantize(centroids, features);
    end
end