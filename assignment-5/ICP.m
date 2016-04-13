%{
ICP algorithm:

- takes: Base point cloud, target point cloud
- returns: Rotation and translation matrix
%}

function [rotation, translation, err] = ICP(source, target, niter, remove_outliers)
    if nargin < 4
        remove_outliers = false;
    end
    display(sprintf('Removing outliers: %d', remove_outliers));
    rotation = eye(3, 3);
    translation = zeros(3, 1);
    
    for iter=1:niter
        % Step 2: Determine which points are closest.
        closest_points = zeros(1, size(source, 2));
        min_distances = zeros(1, size(source, 2));

        % iterate through points in source cloud
        %display('Computing distances');
        for x = 1:size(source, 2)
            distance2 = sum(bsxfun(@minus, target, source(:, x)).^2, 1);
            [min_distances(x), closest_points(x)] = min(distance2, [], 2);
        end
        err = mean(min_distances);
        display(sprintf('MSE %.6f', err));

        if remove_outliers
            threshold = max(min_distances) * 9 / 10 + min(min_distances) * 19 / 10;

            source = source(:, min_distances < threshold);
            closest_points = closest_points(min_distances < threshold);
        end

        % Step 3: Do an SVD of matrix H
        matched_target = target(:, closest_points);

        % calculate average centers of mass.
        ps_avg = mean(source, 2);
        pt_avg = mean(matched_target, 2);

        % center the points by subtracting the average
        centered_source = bsxfun(@minus, source, ps_avg);
        centered_target = bsxfun(@minus, matched_target, pt_avg);

        H = centered_source * centered_target';

        % Perform the SVD
        [U, ~, V] = svd(H);
        R = V * diag([1 1 det(U*V')]) * U';

        t = pt_avg - R * ps_avg;
        source = bsxfun(@plus, R * source, t);

        rotation = R * rotation;
        translation = R * translation + t;
    end
end