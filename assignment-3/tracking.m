function tracking()
    dirName = '/home/ignotus/Development/cv1/assignment-3/person_toy/';
    listing = dir(fullfile(dirName, '*.jpg'));
    files = { listing.name };
    
    first_file_path = fullfile(dirName, files{1});
    img = im2double(imread(first_file_path));
    [h, w, ~] = size(img);
    
    img = zeros(h, w, length(files));

    % stacks images to form a tensor
    for i=1:numel(files)
        img(:,:,i) = sum(im2double(imread(fullfile(dirName, files{i}))), 3);
    end
    
    sigma = 3;
    kernel_length = 11;
    radius = floor(kernel_length / 2);
    G = gaussian(sigma, kernel_length);
    Gd = gaussianDer(G, sigma);

    
    [~, r, c] = harris(first_file_path);
    region_radius = 7;
    
    fid = figure;
    writerObj = VideoWriter('out.avi');
    writerObj.FrameRate = 60;
    open(writerObj); 
    
    % for each frame
    for i=1:numel(files)-1
        % Computes derivatives
        Id = zeros(h, w, 3);
        for x=radius+1:w-radius
            for y=1:h
                Id(y, x, 1) = sum(Gd' .* img(y, x-radius:x+radius, i));
            end
        end

        for x=1:w
            for y=radius+1:h-radius
                Id(y, x, 2) = sum(Gd .* img(y-radius:y+radius, x, i));
            end
        end

        Id(:,:,3) = img(:,:,i + 1) - img(:,:,i);
        
        pause(0.1);
        figure(fid);
        
        imshow(img(:,:, i));
        hold on;
        
        v = zeros(length(r), 2);
        % for each corner point
        for j=1:length(r)
            corner_x = r(j);
            corner_y = c(j);
            
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
        
        r = int16(double(r) + v(:,1)');
        c = int16(double(c) + v(:,2)');
        
        plot(r, c, 'go');
        frame = getframe(gcf);
        writeVideo(writerObj, frame);
        hold off
    end
    
    close(writerObj);
end

