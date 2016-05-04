% 1.3: Normalized Eight Point algorithm with RANSAC

function part1_3()
    
    % path to test with
    path1 = 'House/frame00000001.png';
    path2 = 'House/frame00000002.png';
    
    
    iters = 10; % number of RANSAC iterations
    N = 8; % Sample size
    threshold = 10000; % Sampson distance threshold
    
    
    format long g
    % Obtain the matches. 
    [fr1,fr2,matches] = interest_points(path1, path2);
    
    %% RANSAC
    max_inliers = 0;
    inlier_points = [];
    F_max = 0;
    
    P_1 = vertcat(fr1(1:2,:), ones(1, size(fr1,2)));
    P_2 = vertcat(fr2(1:2,:), ones(1, size(fr2,2)));
    
    for i = 1:iters
        A = zeros(N,9);
        
        % Randomly sample 8 points
        sample = datasample(matches, N, 2);
        
        % Find the coordinates of the matching points
        X_1 = fr1(1,sample(1,:));
        Y_1 = fr1(2,sample(1,:));
        
        X_2 = fr2(1,sample(2,:));
        Y_2 = fr2(2,sample(2,:));
        
         % construct the transformation
        [X_1,Y_1, T_1] =transformation_T(X_1,Y_1);
        [X_2,Y_2, T_2] =transformation_T(X_2,Y_2);
        
        % iterate over all the points
        for j = 1:N
            A(j,:) = [X_1(j)*X_2(j), X_1(j)*Y_2(j), X_1(j), Y_1(j)*X_2(j), Y_1(j)*Y_2(j), Y_1(j), X_2(j), Y_2(j), 1];
        end
        
        % Perform an SVD of A
        [U,S,V] = svd(A);

        % reconstruct F
        temp = V(N,:);
        F = [[temp(1) temp(2) temp(3)]; [temp(4) temp(5) temp(6)]; [temp(7) temp(8) temp(9)]];

        % Enforce singularity
        [U_f, D_f, V_f] = svd(F);
        D_f(size(D_f,1), size(D_f,1)) = 0 ;
        F = U_f*D_f*V_f';

        % Denormalization
        F = T_2'*F*T_1;
        
        temp_inliers = [];
        
        % Check the sampsom distance to count inliers
        inliers = 0;
        for h=1:size(matches, 2)
            
            num = (P_2(:, h)'*F*P_1(:,h))^2;
            a = F*P_1(:,h);
            b = F'*P_2(:,h);
            denom = (a(1))^2+(a(2))^2+ (b(1))^2+(b(2))^2;
            
            sampson = num/denom;
            if sampson < threshold
                inliers = inliers + 1;
                temp_inliers = [temp_inliers; P_1(:,h)]
            end
        end
        
        if inliers > max_inliers
            max_inliers = inliers;
            F_max = F;
            inlier_points = temp_inliers;
        end
        
    end
    
    im1 = imread(path1);
    figure 
    imshow(im1);
    hold on 
    plot(inlier_points(1,:),inlier_points(2,:),'go');
    
    
    
end