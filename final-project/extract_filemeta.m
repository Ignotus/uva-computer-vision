function [folder, file_name] = extract_filemeta(tline)
    folder = strsplit(tline{1}, '/');

    file_name = folder(2);
    folder = folder(1);
end