function hist = quantize_files(files, centroids, type, kp_or_dense)
    hist = 0;
    for file=files
        [folder, file_name] = extract_filemeta(file);
        output_file = descriptor_file_name(folder, type, kp_or_dense, file_name);
        
        load(output_file{1});
        features = double(features);
        if hist == 0
            hist = quantize(centroids, features);
        else
            hist = [hist; quantize(centroids, features)];
        end
    end
    hist = hist';
end