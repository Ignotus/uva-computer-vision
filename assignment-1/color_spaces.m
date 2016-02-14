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
        new_img = cat(3, o1, o2, o3);
    %% Normalized RGB
    elseif strcmp(color_space, 'rgb')
        norm = R + G + B;
        r = R ./ norm;
        g = G ./ norm;
        b = B ./ norm;
        new_img = cat(3, r, g, b);
    %% HSV
    elseif strcmp(color_space, 'hsv')
        new_img = rgb2hsv(img);
    end
    subplot(3, 3,1);
    imshow(new_img(:,:,1));
    subplot(3,3,2);
    imshow(new_img(:,:,2));
    subplot(3,3,3);
    imshow(new_img(:,:,3));
end

