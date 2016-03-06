function tracking(dir_name, file_pattern, output_file)
    sigma = 5;
    kernel_length = 100;
    region_radius = 7;
    threshold = 1.0/1000000000;
    
    listing = dir(fullfile(dir_name, file_pattern));
    
    files = { listing.name };
    
    first_file_path = fullfile(dir_name, files{1});
    img = im2double(imread(first_file_path));
    [h, w, d] = size(img);
    
    % Stacking all images together
    img = zeros(h, w, length(files));
    
    G = gaussian(sigma, kernel_length);
    Gd = gaussianDer(G, sigma);

    % stacks images to form a tensor
    for i=1:numel(files)
        % summing the 3rd axis up to compute intensity
        img(:,:,i) = sum(im2double(imread(fullfile(dir_name, files{i}))), 3);
    end
    
    rgb = zeros(h, w, d, length(files));
    % stacks original rgb images
    for i=1:numel(files)
        rgb(:,:,:,i) = im2double(imread(fullfile(dir_name, files{i})));
    end
    
    [~, r, c] = harris(first_file_path, kernel_length, sigma, threshold);
    
    fid = figure;
    writerObj = VideoWriter(output_file);
    writerObj.FrameRate = 15;
    open(writerObj); 
    
    % for each frame
    for i=1:numel(files)-1
        % Computes derivatives
        Id = zeros(h, w, 3);
        Id(:,:,1) = conv2(img(:,:,i), Gd, 'same');
        Id(:,:,2) = conv2(img(:,:,i), Gd', 'same');

        Id(:,:,3) = img(:,:,i + 1) - img(:,:,i);
        
        
        figure(fid);
        
        imshow(rgb(:,:,:,i));
        hold on;
        
        v = zeros(length(r), 2);
        % for each corner point
        for j=1:length(r)
            corner_x = c(j);
            corner_y = r(j);
            
            % computes a region boundary
            begin_x = max(1, corner_x - region_radius);
            begin_y = max(1, corner_y - region_radius);
            end_x = min(w, corner_x + region_radius);
            end_y = min(h, corner_y + region_radius);
            
            dx = end_x - begin_x + 1;
            dy = end_y - begin_y + 1;
            A = zeros(dx * dy, 2);
            b = zeros(dx * dy, 1);
            
            for x=0:dx-1
                for y=0:dy-1
                    idx = y * dx + x + 1;
                    A(idx,:) = Id(begin_y + y, begin_x + x,1:2);
                    b(idx, 1) = -Id(begin_y + y, begin_x + x,3);
                end
            end
            
            v(j,:) = linsolve(A' * A, A' * b);
        end
        
        %% Updating corner points estimation
        r = int16(double(r) + v(:,2));
        c = int16(double(c) + v(:,1));
        
        plot(c, r, 'b^');
        frame = getframe(gcf);
        writeVideo(writerObj, frame);
        hold off
    end
    
    close(writerObj);
end

