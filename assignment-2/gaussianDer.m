function [imOut, Gd] = gaussianDer(image_path, G, sigma)
    img = im2double(imread(image_path));
    [w, ~] = size(G);
    Gd = zeros(w, 1);
    radius = floor(w / 2);
    for x=1:w
        Gd(x, 1) = - (radius + 1 - x) / (sigma^2) * G(x, 1);
    end
    
    [h, w, d] = size(img);
    imOut = zeros(h, w, d);
    for x=radius+1:w-radius
        for y=1:h
            for z=1:3
                imOut(y, x, z) = sum(Gd' .* img(y, x-radius:x+radius, z));
            end
        end
    end
    
    %% Multiplying with 50 to increase intensity
    imshow(50 * im2double(imOut));
end