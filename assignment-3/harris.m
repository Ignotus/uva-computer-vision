function [H, r, c] = harris(image_path)
    img = im2double(imread(image_path));
    
    kernel_length = 11;
    radius = floor(kernel_length / 2);
    sigma = 3;
    G = gaussian(sigma, kernel_length);
    Gd = gaussianDer(G, sigma);
    
    [h, w, d] = size(img);
    Ix = zeros(h, w, d);
    for x=radius+1:w-radius
        for y=1:h
            for z=1:d
                Ix(y, x, z) = sum(Gd' .* img(y, x-radius:x+radius, z));
            end
        end
    end
    
    Iy = zeros(h, w, d);
    for x=1:w
        for y=radius+1:h-radius
            for z=1:d
                Iy(y, x, z) = sum(Gd .* img(y-radius:y+radius, x, z));
            end
        end
    end
    
    A = zeros(h, w, d);
    B = zeros(h, w, d);
    C = zeros(h, w, d);
    G = G * G';
    
    Ix2 = Ix .^ 2;
    IxIy = Ix .* Iy;
    Iy2 = Iy .^ 2;
    
    for z=1:d
        A(:,:,z) = conv2(Ix2(:,:,z), G, 'same');
        B(:,:,z) = conv2(IxIy(:,:,z), G, 'same');
        C(:,:,z) = conv2(Iy2(:,:,z), G, 'same');
    end
    
    H = (A .* C - B .^2) - 0.04 * (A + C).^2;
    H = sum(H, 3);

    imshow(img);
    hold on;
    radius = 5;
    
    r = [];
    c = [];
    for x=radius+1:w-radius
        for y=radius+1:h-radius
            ch = H(y, x);
            is_not_max = false;
            for x_h=x-radius:x+radius
                for y_h=y-radius:y+radius
                    if H(y_h, x_h) > ch
                        is_not_max = true;
                        break
                    end
                end
                if is_not_max
                    break
                end
            end
            
            if is_not_max == false
                c = [c y];
                r = [r x];
                plot(x, y, 'go');
            end
        end
    end
end
