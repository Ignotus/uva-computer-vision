function photometric_stereo()
    img1 = imread('sphere1.png');
    img2 = imread('sphere2.png');
    img3 = imread('sphere3.png');
    img4 = imread('sphere4.png');
    img5 = imread('sphere5.png');
    
    k = 1;
    
    v_x = 1;
    v_y = 1;
    v_z = 0.5;
    V = [[ 0  0 v_z];
         [-v_x  v_y v_z];
         [ v_x  v_y v_z];
         [-v_x -v_y v_z];
         [ v_x -v_y v_z]];

    %% Absolute lengths of V
    N = sqrt(sum(abs(V).^2, 2));
    V = bsxfun(@rdivide, V, N);
    
    V = k * V;
    
    [w, h] = size(img1);
    g = zeros(w, h, 3);
    for i=1:w
        for j=1:h
            Idiag = double([img1(i, j); img2(i, j); img3(i, j); img4(i, j); img5(i, j)]);
            
            %% first compute g(i, j). linsolve seems to produce more precise
            %% result than with pseudo invert matrix
            I = diag(Idiag);
            [g(i, j, :), ~] = linsolve(I * V, Idiag.^2);
        end
    end
    
    % Computes albedo
    albedo = sqrt(sum(g.^2, 3));
    
    % Normalize pixel norms
    N = bsxfun(@rdivide, g, albedo);
 
    p = bsxfun(@rdivide, N(:,:,1), N(:,:,3));
    q = bsxfun(@rdivide, N(:,:,2), N(:,:,3));
    
    p(isnan(p)) = 0;
    q(isnan(q)) = 0;
    
    deriv2_diff = zeros(w, h);
    %% Second order partial derivative check
    %% http://www.ifp.illinois.edu/~nemanja/cvpr01.pdf . Formula 5
    for i=1:w-1
        for j=1:h-1
            dq = q(i, j) - q(i + 1, j);
            dp = p(i, j) - p(i, j + 1);
            deriv2_diff(i, j) = (dp - dq) ^ 2;
            if deriv2_diff(i, j) > 0.005
                q(i, j) = 0;
                p(i, j) = 0;
            end
        end
    end
   
    Z = zeros(w, h);
    j = 1; %% left column
    for i=2:h
        Z(i, j) = Z(i - 1, j) + q(i, j);
    end
    
    for i=1:h
        for j=2:w
            Z(i, j) =  Z(i, j - 1) + p(i, j);
        end
    end
    
    [X_subsampled, Y_subsampled] = meshgrid(1:32:512, 1:32:512);
    w = length(X_subsampled);
    Z_subsampled = zeros(w, w);
    
    for i=1:w
        for j=1:w
            Z_subsampled(i, j) = Z(X_subsampled(i, j), Y_subsampled(i, j));
        end
    end
    
    [U, V, W] = surfnorm(X_subsampled, Y_subsampled, Z_subsampled);
    
    figure;
    title(strcat('V_x = ', int2str(v_x), '; V_y = ', int2str(v_y), '; V_z = ', int2str(v_z), '; k = ', int2str(k)));
    
    subplot(2, 2, 1);
    imshow(albedo);
    title('Albedo');
    
    subplot(2, 2, 2);
    surf(X_subsampled, Y_subsampled, Z_subsampled, gradient(Z_subsampled));
    xlabel('x'),ylabel('y'),zlabel('z');
    title('Surface mesh');
    
    subplot(2, 2, 3);
    quiver3(X_subsampled, Y_subsampled, Z_subsampled, U, V, W, 0.5);
    xlabel('x'),ylabel('y'),zlabel('z');
    title('Surface normals');
    
    subplot(2, 2, 4);
    [X, Y] = meshgrid(1:512, 1:512);
    surf(X, Y, deriv2_diff, gradient(deriv2_diff));
    xlabel('x'),ylabel('y'),zlabel('deriv2_diff');
    title('Second order derivatives squared difference');
end