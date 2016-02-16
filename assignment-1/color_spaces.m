function color_spaces(image_name, color_space)
    img = double(imread(image_name));
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    %% Opponent color space
    if strcmp(color_space, 'opponent')
        o1 = (R - G) / sqrt(2);
        o2 = (R + G - 2 * B) / sqrt(6);
        o3 = (R + G + B) / sqrt(3);
        c1 = o1;
        c2 = o2;
        c3 = o3;
    %% Normalized RGB
    elseif strcmp(color_space, 'rgb')
        norm = R + G + B;
        r = R ./ norm;
        g = G ./ norm;
        b = B ./ norm;
        c1 = r;
        c2 = g;
        c3 = b;
    %% HSV
    elseif strcmp(color_space, 'hsv')
        new_img = rgb2hsv(img);
        c1 = new_img(:,:,1);
        c2 = new_img(:,:,2);
        c3 = new_img(:,:,3);
    end
    %% im2double automatically scales data if it's required
    subplot(2, 2, 1);
    imshow(im2double(c1));
    subplot(2, 2, 2);
    imshow(im2double(c2));
    subplot(2, 2, 3);
    imshow(im2double(c3));
end

