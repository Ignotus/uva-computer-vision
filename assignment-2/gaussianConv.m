function imOut = gaussianConv(im_path, sigma_x, sigma_y)
    img = im2double(imread(im_path));
    
    [h, w, d] = size(img);
    imOut1 = zeros(h, w, d);
    kernelLength = 7;
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
    
    plot = true;
    if plot
        figure
        subplot(2, 2, 1);
        imshow(imOut);

        G = double(fx' * fy');
        G = G ./ sum(sum(G));

        subplot(2, 2, 2);
        title('Full');
        imOut1 = zeros(h + kernelLength - 1, w + kernelLength - 1, d);

        for z=1:d
            imOut1(:,:,z) = conv2(img(:,:,z), G, 'full');
        end
        imshow(imOut1);

        subplot(2, 2, 3);
        title('Same');
        imOut1 = zeros(h, w, d);

        for z=1:d
            imOut1(:,:,z) = conv2(img(:,:,z), G, 'same');
        end
        imshow(imOut1);

        subplot(2, 2, 4);
        title('Valid');
        imOut1 = zeros(h - kernelLength + 1, w - kernelLength + 1, d);

        for z=1:d
            size(conv2(img(:,:,z), G, 'valid'))
            imOut1(:,:,z) = conv2(img(:,:,z), G, 'valid');
        end
        imshow(imOut1);
    end
end