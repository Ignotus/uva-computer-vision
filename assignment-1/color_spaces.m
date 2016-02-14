function color_spaces(image_name, color_space)
    img = double(imread(image_name));
    %% Opponent color space
    if strcmp(color_space, 'opponent')
        o1 = (img(:,:,1) - img(:,:,2)) / sqrt(2.0);
        o2 = (img(:,:,1) + img(:,:,2) - 2 * img(:,:,3)) / sqrt(6.0);
        o3 = sum(img, 3) / sqrt(3.0);
        subplot(3, 3,1);
        imshow(o1);
        subplot(3,3,2);
        imshow(o2);
        subplot(3,3,3);
        imshow(o3);
    %% Normalized RGB
    elseif strcmp(color_space, 'rgb')
        norm = double(sum(img, 3));
        r = img(:,:,1) ./ norm;
        g = img(:,:,2) ./ norm;
        b = img(:,:,3) ./ norm;
        subplot(3, 3,1);
        imshow(r);
        subplot(3,3,2);
        imshow(g);
        subplot(3,3,3);
        imshow(b);
    elseif strcmp(color_space, 'hsv')
        hsv = rgb2hsv(img);
        subplot(3, 3,1);
        imshow(hsv(:,:,1));
        subplot(3,3,2);
        imshow(hsv(:,:,2));
        subplot(3,3,3);
        imshow(hsv(:,:,3));
    end
end

