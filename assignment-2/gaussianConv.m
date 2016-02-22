function imOut = gaussianConv(im_path, sigma_x, sigma_y)
    img = im2double(imread(im_path));
    
    [h, w, d] = size(img);
    imOut1 = zeros(h, w, d);
    kernelLength = 11;
    radius = floor(kernelLength / 2);
    %% Gaussian filter for Ox
    fx = gaussian(sigma_x, kernelLength)';
    fx = round(fx ./ min(fx));
    %% Gaussian filter for Oy
    fy = gaussian(sigma_y, kernelLength);
    fy = round(fy ./ min(fy));
    for x=radius+1:w-radius
        for y=1:h
            for z=1:d
                imOut1(y, x, z) = sum(fx .* img(y, x-radius:x+radius, z)) / sum(fx);
            end
        end
    end
    
    imOut = zeros(h, w, d);
    for y=radius+1:h-radius
        for x=1:w
            for z=1:d
                imOut(y, x, z) = sum(fy .* imOut1(y - radius:y + radius, x, z)) / sum(fy);
            end
        end
    end
    
    %% Applying 2D filter and compare with the previous result
    G = double(fx' * fy');
    G = G ./ sum(sum(G));
    imOut2 = zeros(h, w, d);
    for x=radius+1:w-radius
        for y=radius+1:h-radius
            for z=1:d
                imOut2(y, x, z) = sum(sum(G .* img(y-radius:y+radius, x-radius:x+radius, z)));
            end
        end
    end
    
    plot = false;
    if plot
        figure
        subplot(1, 3, 1);
        imshow(img);
        title('Original image');
        
        subplot(1, 3, 2);
        imshow(imOut1);
        title('After 1D filter Ox');
        
        subplot(1, 3, 3);
        imshow(imOut);
        title('After 1D filter Oy');
        
        figure
        difference = abs(imOut2 - imOut);
        [X_subsampled, Y_subsampled] = meshgrid(1:32:w, 1:32:h);
        
        [h_s, w_s] = size(X_subsampled);
        Z_subsampled = zeros(h_s, w_s);
        for y=1:h_s
            for x=1:w_s
                Z_subsampled(y, x) = difference(X_subsampled(y, x), Y_subsampled(y, x));
            end
        end
        surf(X_subsampled, Y_subsampled, Z_subsampled, gradient(Z_subsampled));
        
        title('Diff. between 2 conv of 1D filters and 1 conv of 2D');
        
        figure
        subplot(1, 5, 1);
        imshow(imOut);
        title('2 conv 1D');
        
        subplot(1, 5, 2);
        imshow(imOut);
        title('1 conv 2D');

        subplot(1, 5, 3);
        imOut1 = zeros(h + kernelLength - 1, w + kernelLength - 1, d);

        for z=1:d
            imOut1(:,:,z) = conv2(img(:,:,z), G, 'full');
        end
        imshow(imOut1);
        title('Full');

        subplot(1, 5, 4);
        imOut1 = zeros(h, w, d);

        for z=1:d
            imOut1(:,:,z) = conv2(img(:,:,z), G, 'same');
        end
        imshow(imOut1);
        title('Same');

        subplot(1, 5, 5);
        imOut1 = zeros(h - kernelLength + 1, w - kernelLength + 1, d);

        for z=1:d
            size(conv2(img(:,:,z), G, 'valid'))
            imOut1(:,:,z) = conv2(img(:,:,z), G, 'valid');
        end
        imshow(imOut1);
        title('Valid');
    end
end