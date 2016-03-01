function [v] = optical_flow(img1_path, img2_path)
    img1 = imread(img1_path);
    img1 = sum(img1, 3);
    img2 = imread(img2_path);
    img2 = sum(img2, 3);
    
    kernel_length = 11;
    radius = floor(kernel_length / 2);
    sigma = 3;
    G = gaussian(sigma, kernel_length);
    Gd = gaussianDer(G, sigma);
        
    [h, w] = size(img1);
    Id = zeros(h, w, 3);
    for x=radius+1:w-radius
        for y=1:h
            Id(y, x, 1) = sum(Gd' .* img1(y, x-radius:x+radius));
        end
    end
    
    for x=1:w
        for y=radius+1:h-radius
            Id(y, x, 2) = sum(Gd .* img1(y-radius:y+radius, x));
        end
    end
    
    Id(:,:,3) = img2 - img1;
    
    v = zeros(length(1:15:h-15), length(1:15:w-15), 2);
    for x=1:15:w-15
        for y=1:15:h-15
            A = zeros(225, 2);
            b = zeros(225, 1);
            for i=0:14
                for j=0:14
                    idx = j * 15 + i + 1;
                    A(idx,:) = Id(j + y, i + x,1:2);
                    b(idx, 1) = Id(j + y, i + x,3);
                end
            end
            
            v_x = (x + 14) / 15;
            v_y = (y + 14) / 15;
            v(v_y, v_x,:) = linsolve(A' * A, -A' * b);
        end
    end
    
    v(isnan(v)) = 0;
  
    [x,y] = meshgrid(1:15:w-15,1:15:h-15);
    
    figure
    quiver(x,y, v(:,:,1), v(:,:,2));
end

