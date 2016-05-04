% interest_points
% Takes: Paths to image pair
% Returns:

function [fr1,fr2,matches] = interest_points(path1, path2)
    
    % read the images
    im1 = imread(path1);
    im2 = imread(path2);
    
    % Check whether they are color or gray
    if length(size(im1)) == 3
        im1 = rgb2gray(im1);
    end
    
    if length(size(im2)) == 3
        im2 = rgb2gray(im2);
    end
    
    % conver to single
    im1 = im2single(im1);
    im2 = im2single(im2);
    
    % run sift with matching features.
    [fr1, desc1] = vl_sift(im1);
    [fr2, desc2] = vl_sift(im2);
    
    [matches, ~] = vl_ubcmatch(desc1, desc2);
end

