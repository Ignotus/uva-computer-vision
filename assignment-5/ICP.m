%{
ICP algorithm:

- takes: Base point cloud, target point cloud
- returns: Rotation and translation matrix
%}

function [rotation, translation, err] = ICP(source, target)
    % Step 2: Determine which points are closest.
    closest_points = zeros(1, size(source, 2));
    
    % iterate through points in source cloud
    err = 0;
    for x = 1:size(source, 2)
        distance2 = sum(bsxfun(@minus, target, source(:, x)).^2, 1);
        [min_distance, closest_points(x)] = min(distance2, [], 2);
        err = err + min_distance;
    end
    
    
    % Step 3: Do an SVD of matrix H
    target = target(:, closest_points);
    
    % calculate average centers of mass.
    ps_avg = sum(source, 2) ./ size(source, 2);
    pt_avg = sum(target, 2) ./ size(target, 2);
    
    % center the points by subtracting the average
    centered_source = bsxfun(@minus, source, ps_avg);
    centered_target = bsxfun(@minus, target, pt_avg);
    
    H = centered_source * centered_target';
    
    % Perform the SVD
    [U, ~, V] = svd(H);
    rotation = V * U';

    translation = ps_avg - rotation * pt_avg;
end