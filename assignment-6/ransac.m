function [F_max, inlier_points_p1, inlier_points_p2] = ransac(fr1, fr2, matches, teddy)
%% PARAMETERS
if teddy
    iters = 1000; % number of RANSAC iterations
    threshold = 10;
else
    iters = 200;
    threshold = 1; % Sampson distance threshold
end
N = 9; % Sample size


%% RANSAC
max_inliers = 0;
min_outliers = 0;
inlier_points_p1 = [];
inlier_points_p2 = [];

F_max = 0;

% Using only matched points
P_1 = vertcat(fr1(1:2, matches(1, :)), ones(1, size(matches,2)));
P_2 = vertcat(fr2(1:2, matches(2, :)), ones(1, size(matches,2)));

for i = 1:iters
    % Randomly sample N points
    r = randsample(size(matches, 2), N);
    
    % Find the coordinates of the matching points
    X_1 = P_1(1, r);
    Y_1 = P_1(2, r);
    
    X_2 = P_2(1, r);
    Y_2 = P_2(2, r);
    
    
    % construct the transformation
    [X_1, Y_1, T_1] = transformation_T(X_1, Y_1);
    [X_2, Y_2, T_2] = transformation_T(X_2, Y_2);
    
    A = vertcat(X_1 .* X_2, X_1 .* Y_2, X_1,...
                Y_1 .* X_2, Y_1 .* Y_2, Y_1,...
                X_2, Y_2, ones(size(Y_2)));
    
    A = A';
    
    assert(all(A(:, end) == 1));
    
    % Perform an SVD of A
    [~, ~, V] = svd(A);

    % reconstruct F
    F = reshape(V(:, end), 3, 3);
    
    % Enforce singularity
    [U_f, D_f, V_f] = svd(F);
    D_f(end, end) = 0;
    F = U_f * D_f * V_f';
    % Checks that matrix rank is 2 after
    if rank(F) ~= 2
        continue
    end
    
    % Denormalization
    F = T_2' * F * T_1;
    %assert(all(abs(sum(P_2(:, r)' * F .* P_1(:, r)', 2)) < 0.2));
    temp_inliers_p1 = [];
    temp_inliers_p2 = [];
    
    % Check the sampsom distance to count inliers
    inliers = 0;
    outliers = 0;
    for h=1:size(matches, 2)
        
        num = (P_2(:, h)' * F * P_1(:,h)).^2;
        a = F * P_1(:,h);
        b = F' * P_2(:,h);
        
        sampson = num / sum(a(1:2).^2 + b(1:2).^2);
        
        if sampson < threshold
            inliers = inliers + 1;
            temp_inliers_p1 = horzcat(temp_inliers_p1, P_1(:,h));
            temp_inliers_p2 = horzcat(temp_inliers_p2, P_2(:,h));
        else
            outliers = outliers + 1;
        end
    end
    
    if inliers > max_inliers
        max_inliers = inliers;
        min_outliers = outliers;
        F_max = F;
        inlier_points_p1 = temp_inliers_p1;
        inlier_points_p2 = temp_inliers_p2;
    end
   
    max_inliers;
    min_outliers;
end

min_outliers