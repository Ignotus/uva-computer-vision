function labels = extract_labels(files)
    labels = zeros(length(files), 1);
    for i=1:length(files)
        file = files(i);
        [folder, ~] = extract_filemeta(file);
        lexemes = strsplit(folder{1}, '_');
        label = lexemes(1);
        if strcmp(label, 'airplanes') == 1
            labels(i) = 1;
        elseif strcmp(label, 'cars') == 1
            labels(i) = 2;
        elseif strcmp(label, 'faces') == 1
            labels(i) = 3;
        elseif strcmp(label, 'motorbikes') == 1
            labels(i) = 4;
        end
    end
end