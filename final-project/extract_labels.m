function labels = extract_labels(files)
    labels = [];
    for file=files
        [folder, ~] = extract_filemeta(file);
        lexemes = strsplit(folder{1}, '_');
        label = lexemes(1);
        if strcmp(label, 'airplanes') == 1
            labels = [labels 1];
        end
        if strcmp(label, 'cars') == 1
            labels = [labels 2];
        end
        if strcmp(label, 'faces') == 1
            labels = [labels 3];
        end
        
        if strcmp(label, 'motorbikes') == 1
            labels = [labels 4];
        end
    end
end