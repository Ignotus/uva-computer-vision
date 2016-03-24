function files = file_list(file)
    files = {};
    fid = fopen(file);
    tline = fgetl(fid);
    while ischar(tline)
        files{end+1} = tline;
        tline = fgetl(fid);
    end
    
    fclose(fid);
end