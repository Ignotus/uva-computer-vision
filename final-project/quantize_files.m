function histograms = quantize_files(files, centroids, type, kp_or_dense)
    histograms = 0;
    for file=files
        [folder, file_name] = extract_filemeta(file);
        output_file = descriptor_file_name(folder, type, kp_or_dense, file_name);
        
        load(output_file{1});
        features = double(features);
        if histograms == 0
            histograms = quantize(centroids, features);
        else
            histograms = [histograms; quantize(centroids, features)];
        end
    end
    histogram = histogram';
end