% 1.3: Normalized Eight Point algorithm with RANSAC

function part1_3()

close all;
clear all;
% path to test with
path1 = 'House/frame00000001.png';
path2 = 'House/frame00000002.png';

%path1 = 'temple/temple0001.png';
%path2 = 'temple/temple0002.png';

%path1 = 'Corridor/bt.000.pgm';
%path2 = 'Corridor/bt.001.pgm';

format long g % turn off scientific notation

% Obtain the matches.
[fr1, fr2, matches] = interest_points(path1, path2);

[F, inlier_points_p1, inlier_points_p2] = ransac(fr1, fr2, matches);

im1 = imread(path1);
im2 = imread(path2);

% 3 coordinates of the equation ax + by + z = 0
epipolar_lines_1 = (inlier_points_p2' * F)';
draw_line(inlier_points_p1(1:2, :), epipolar_lines_1, im1);

epipolar_lines_2 = F * inlier_points_p1;
draw_line(inlier_points_p2(1:2, :), epipolar_lines_2, im2);

% http://www.maths.lth.se/matematiklth/personal/calle/datorseende13/notes/forelas6.pdf
P1= [1 0 0 0;
    0 1 0 0;
    0 0 1 0];

% Solve and find e_2: F' e_2 = 0
% http://stackoverflow.com/questions/26681523/matlab-3d-reconstruction-using-eight-point-algorithm

[~, ~, V] = svd(F');

ep = V(:,3)/V(3,3);

P2 = [skew(ep)*F,ep]