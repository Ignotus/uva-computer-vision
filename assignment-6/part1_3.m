% 1.3: Normalized Eight Point algorithm with RANSAC

function part1_3()
clear all;
close all;

format long g % turn off scientific notation

nframes = 49;
debug = false;

prev_frame = frame(1);
if length(size(prev_frame)) == 3
    prev_frame = rgb2gray(prev_frame);
end

prev_frame = im2single(prev_frame);
[fr1, desc1] = vl_sift(prev_frame);

for i=2:nframes
    i
    % path to test with
    current_frame = frame(i);

    % Obtain the matches.
    [fr2, matches, desc2, current_frame] = interest_points(prev_frame, current_frame,...
                                                           fr1, desc1,...
                                                           debug);

    [F, inlier_points_p1, inlier_points_p2] = ransac(fr1, fr2, matches);

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
        point_view_mat = zeros(nframes - 1, size(inlier_points_p2, 2), 2);
        point_view_mat(i-1,:,:) = inlier_points_p2';
    else
        %% Iterate across inliers!
        for j = 1:size(inlier_points_p2, 2)
            % Finding number of matched points from the previous iteration
            point_match = point_view_mat(i-2,:,1) == inlier_points_p1(1,j)...
                & point_view_mat(i-2,:,2) == inlier_points_p1(2,j);
            n_point_match = sum(point_match);

            if n_point_match == 1
                %% Insert to the matched position
                point_view_mat(i-1,point_match,:) = inlier_points_p2(:,j);
            elseif n_point_match == 0
                %% Add a new column to point-view matrix for each newly
                %% introduced point.
                point_view_mat(:,end+1,:) = 0;

                %% Adding this point to the last column
                point_view_mat(i-1,end,:) = inlier_points_p2(:,j);
            else
                %% IGNORE THAT CASE
            end
        end
    end

    %% Prepare the next iteration
    prev_frame = current_frame;
    fr1 = fr2;
    desc1 = desc2;
end

%% Normalize the point coordinates by translating them to the mean of the
%% points in each view
point_view_mat = bsxfun(@minus, point_view_mat, mean(point_view_mat, 2));

%% Constructing the measurement matrix D
[M, N, ~] = size(point_view_mat);
D = zeros(2 * M, N);
for i=1:2
	D(i:2:end,:) = point_view_mat(:,:,i);
end

%% Applying SVD
[U, W, V] = svd(D);
size(U)
size(W)
size(V)

%% Factorizing the measurement matrix. Page 97. Jan van Gemert's lecture.
U3 = U(:,1:3);
W3 = W(1:3,1:3);
V3 = V(:,1:3)';

% Page 99
M = U3 * sqrt(W3);
S = sqrt(W3) * V3;

C = ones(1, size(S, 2));
C(1,2:end) = 2;
visualize(S, C);