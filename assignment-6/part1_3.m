% 1.3: Normalized Eight Point algorithm with RANSAC

function part1_3()
clear all;
close all;

format long g % turn off scientific notation

nframes = 2;
step_size = 1;
debug = false;

prev_frame = frame(1);
if length(size(prev_frame)) == 3
    prev_frame = rgb2gray(prev_frame);
end

prev_frame = im2single(prev_frame);
[fr1, desc1] = vl_sift(prev_frame);

for i=step_size * 2:step_size:nframes
    i
    % path to test with
    current_frame = frame(i);

    % Obtain the matches.
    [fr2, matches, desc2] = interest_points(prev_frame, current_frame,...
                                            fr1, desc1,...
                                            debug);

    [F, inlier_points_p1, inlier_points_p2] = ransac(fr1, fr2, matches);

    if debug
        im1 = prev_frame;
        im2 = current_frame;

        % 3 coordinates of the equation ax + by + z = 0
        epipolar_lines_1 = (inlier_points_p2' * F)';
        draw_line(inlier_points_p1(1:2, :), epipolar_lines_1, im1);

        epipolar_lines_2 = F * inlier_points_p1;
        draw_line(inlier_points_p2(1:2, :), epipolar_lines_2, im2);
    end
    
    prev_frame = current_frame;
    fr1 = fr2;
    desc1 = desc2;
end