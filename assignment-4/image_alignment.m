function image_alignment()
    P = 3;
    N = 10;

    im1 = single(imread('boat/img1.pgm'));
    im2 = single(imread('boat/img2.pgm'));
    [frames1, desc1] = vl_sift(im1);
    [frames2, desc2] = vl_sift(im2);
    
    [matches, ~] = vl_ubcmatch(desc1, desc2);

    inlier_counter_max = 0;
    M_max = 0;
    T_max = 0;
    for n=1:N
        A = zeros(P * 2, 6);
        b = zeros(P * 2, 1);
        
        samples = datasample(matches, P, 2);
        for i=1:P
            first_row = i * 2 - 1;
            second_row = i * 2;
            A(first_row, 5) = 1;
            A(second_row, 6) = 1;
            
            xy = frames1(1:2, samples(1, i));
            b(first_row:second_row) = frames2(1:2, samples(2, i));
            
            A(first_row, 1:2) = xy;
            A(second_row, 3:4) = xy;
        end
        
        transform_matrix = linsolve(A, b);
        
        M = [transform_matrix(1) transform_matrix(2);
             transform_matrix(3) transform_matrix(4)];
        T = [transform_matrix(5); transform_matrix(6)];
        
        inlier_counter = 0;
        for i=1:size(matches, 2)
            xy = M * frames1(1:2, matches(1, i)) + T;
            xy_gt = frames2(1:2, matches(2, i));
            if sqrt(sum((xy - xy_gt) .^2)) <= 10
                inlier_counter = inlier_counter + 1;
            end
        end
        if inlier_counter > inlier_counter_max
            inlier_counter_max = inlier_counter;
            M_max = M;
            T_max = T;
        end
    end
    
    
    [h, w] = size(im1);
    [y, x] = meshgrid(1:h, 1:w);
    y = reshape(y.', 1, []);
    x = reshape(x.', 1, []);
    
    xy_ = uint16(ceil([x;y]' * M_max' + repmat(T_max', [length(x), 1])));
    % A hack to plot an image. Coordinates cannot be negative values
    xy_ = xy_ - min(xy_, 2) + 1;
    im3 = zeros(max(xy_(2,:)), max(xy_(1,:)));
    size(im3)
    size(xy_)
    
    for i=1:length(xy_)
        im3(xy_(i, 2), xy_(i, 1)) = im1(y(i), x(i));
    end
    
    figure;
    image(im3);
    
    Tr = zeros(3, 3);
    Tr(1:2, 1:2) = M_max';
    Tr(3, 3) = 1;   
    
    Tr = maketform('affine', Tr);
    tformfwd(T_max, Tr);
    im3 = imtransform(im1, Tr);
    
    figure;
    imshowpair(im3, im2, 'montage')
end


