% 1.3: Normalized Eight Point algorithm with RANSAC

function part1_3()
clear all;
close all;

format long g % turn off scientific notation

%% Parameters
nframes = 49;
debug = false;
stitch = false;
use_icp = true;
teddy = false;
%% Numbers of consecutive frames to take in consideration
K = 4;

prev_frame = frame(1, teddy);
[fr1, desc1] = vl_sift(prev_frame);

display('Building point view matrix');
for i=2:nframes
    display(sprintf('Iteration %d', i));
    % path to test with
    current_frame = frame(i, teddy);

    % Obtain the matches.
    [fr2, matches, desc2, current_frame] = interest_points(prev_frame, current_frame,...
                                                           fr1, desc1,...
                                                           debug);

    [F, inlier_points_p1, inlier_points_p2] = ransac(fr1, fr2, matches);
    display(sprintf('Inliers: %d', size(inlier_points_p2, 2)));
    if debug
        im1 = prev_frame;
        im2 = current_frame;

        % 3 coordinates of the equation ax + by + z = 0
        epipolar_lines_1 = (inlier_points_p2' * F)';
        draw_line(inlier_points_p1, epipolar_lines_1, im1);

        epipolar_lines_2 = F * inlier_points_p1;
        draw_line(inlier_points_p2, epipolar_lines_2, im2);
    end
    
    % Return only X and Y coordinates
    inlier_points_p1 = inlier_points_p1(1:2,:);
    inlier_points_p2 = inlier_points_p2(1:2,:);
    
    if i == 2
        point_view_mat = zeros(nframes, size(inlier_points_p2, 2), 2);
        point_view_mat(i-1,:,:) = inlier_points_p1';
        point_view_mat(i,:,:) = inlier_points_p2';
    else
        %% Iterate across inliers!
        for j = 1:size(inlier_points_p2, 2)
            % Finding number of matched points from the previous iteration
            point_match = point_view_mat(i-1,:,1) == inlier_points_p1(1,j)...
                & point_view_mat(i-1,:,2) == inlier_points_p1(2,j);
            n_point_match = sum(point_match);

            if n_point_match == 1
                %% Insert to the matched position
                point_view_mat(i,point_match,:) = inlier_points_p2(:,j);
            elseif n_point_match == 0
                %% Add a new column to point-view matrix for each newly
                %% introduced point.
                point_view_mat(:,end+1,:) = 0;

                %% Adding this point to the last column
                point_view_mat(i,end,:) = inlier_points_p2(:,j);
            else
                %% IGNORE THAT CASE
                %% display(sprintf('Several matches: %d', n_point_match));
            end
        end
    end

    %% Prepare the next iteration
    prev_frame = current_frame;
    fr1 = fr2;
    desc1 = desc2;
end

if debug
    figure;
    imshow(squeeze(point_view_mat(:,:,1)) == 0 & squeeze(point_view_mat(:,:,2)) == 0);
end

merged_points_transformed = [];
merged_points = [];
C = [];

rotation = zeros(nframes-K, 3, 3);
translation = zeros(nframes-K, 3, 1);

display('Stitching');
for i=1:1:nframes-K
    display(sprintf('Iteration %d', i))
    local_point_view = point_view_mat(i:i+K-1,:,:);
    % Finding dense blocks
    local_point_view = local_point_view(:, sum(sum(local_point_view, 3) > 0, 1) > K - 1, :);
    
    %% Normalize the point coordinates by translating them to the mean of the
    %% points in each view
    local_point_view = bsxfun(@minus, local_point_view, mean(local_point_view, 2));
    %% Constructing the measurement matrix D
    [M, N, ~] = size(local_point_view);
    D = zeros(2 * M, N);
    for j=1:2
        D(j:2:end,:) = local_point_view(:,:,j);
    end

    %% Applying SVD
    [U, W, V] = svd(D);

    %% Factorizing the measurement matrix. Page 97. Jan van Gemert's lecture.
    U3 = U(:,1:3);
    W3 = W(1:3,1:3);
    V3 = V(:,1:3)';

    % Page 99
    M = U3 * W3.^10;
    S = W3.^(0.1) * V3;

    merged_points = [merged_points S];
    
    if debug
        scatter3(S(1,:), S(2,:), S(3,:));
    end

    if i > 1
        prev_points = merged_points(:, C == i - K);
        
        min_length = min(size(prev_points, 2), size(S, 2));
        
        if use_icp
            [rotation(i, :, :), translation(i, :, :), ~] = ICP(prev_points, S, 40, debug);
        else
            [~, Z, transform] = procrustes(prev_points(:, 1:min_length)',...
                                           S(:, 1:min_length)', ...
                                           'scaling', false,...
                                           'reflection', false);
            if debug
                visualize([prev_points(:, 1:min_length) Z'], [ones(1, min_length) ones(1, min_length - 1) * 2 10]);
            end

            rotation(i, :, :) = transform.T;
            translation(i, :, :) = transform.c(1, :);
        end
        S = S';
        for k=i:-K:2
            S = bsxfun(@plus, S * squeeze(rotation(k, :, :)), translation(k, :, :));
        end
        S = S';
    end
    merged_points_transformed = [merged_points_transformed S];
    C = [C ones(1, size(S, 2)) * i];
    if stitch == false
        C(1, end) = 10;
        break;
    end
end

visualize(merged_points_transformed, C);