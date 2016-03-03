function [v] = optical_flow(img1_path, img2_path)
    kernel_length = 9;
    sigma = 3;
    
    img1 = imread(img1_path);
    % combines RGB layers to compute intensity
    img1 = sum(img1, 3);
    img2 = imread(img2_path);
    img2 = sum(img2, 3);
    
    Gd = gaussianDer(gaussian(sigma, kernel_length), sigma);
    [h, w] = size(img1);
    Id = zeros(h, w, 3);
    
    Id(:,:,1) = conv2(img1, Gd, 'same');
    Id(:,:,2) = conv2(img1, Gd', 'same');
    Id(:,:,3) = img2 - img1;
    
    v = zeros(length(1:15:h), length(1:15:w), 2);
    for x=1:15:w
        for y=1:15:h
            end_x = min(w - x, 15);
            end_y = min(h - y, 15);
            A = zeros(end_x * end_y, 2);
            b = zeros(end_x * end_y, 1);
            
            for i=0:end_x - 1
                for j=0:end_y - 1
                    idx = j * end_x + i + 1;
                    A(idx,:) = Id(j + y, i + x,1:2);
                    b(idx, 1) = -Id(j + y, i + x,3);
                end
            end
            
            v_x = (x + 14) / 15;
            v_y = (y + 14) / 15;
            [v(v_y, v_x,:), ~] = linsolve(A' * A, A' * b);
        end
    end
    
    v(isnan(v)) = 0;
  
    [x,y] = meshgrid(1:15:w,1:15:h);
    
    figure;
    imshow(imread(img1_path));
    
    imshow(imread(img1_path), 'XData', 1:w, 'YData', 1:h);
    hold on
    quiver(x,y, v(:,:,1), v(:,:,2));
    hold off
    axis on
end

