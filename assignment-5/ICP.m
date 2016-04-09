%{
ICP algorithm:

- takes: Base point cloud, target point cloud
- returns: Rotation and translation matrix
%}

function [rotation, translation, matches, err] = ICP(source, target, niter)
    rotation = eye(3, 3);
    translation = zeros(3, 1);
    matches = zeros(size(target, 2), 1);
    
    for iter=1:niter
        % Step 2: Determine which points are closest.
        closest_points = zeros(1, size(source, 2));

        % iterate through points in source cloud
        display('Computing distances');
        err = 0;
        for x = 1:size(source, 2)
            distance2 = sum(bsxfun(@minus, target, source(:, x)).^2, 1);
            [min_distance, closest_points(x)] = min(distance2, [], 2);
            err = err + min_distance;
        end

        display(sprintf('Error %.2f', err));
        if iter == niter
            matches(unique(closest_points)) = 1;
        end

        % Step 3: Do an SVD of matrix H
        matched_target = target(:, closest_points);

        % calculate average centers of mass.
        ps_avg = sum(source, 2) ./ size(source, 2);
        pt_avg = sum(matched_target, 2) ./ size(matched_target, 2);

        % center the points by subtracting the average
        centered_source = bsxfun(@minus, source, ps_avg);
        centered_target = bsxfun(@minus, matched_target, pt_avg);

        H = centered_source * centered_target';

        % Perform the SVD
        [U, ~, V] = svd(H);
        rotation_local = V * U';

        translation_local = ps_avg - rotation_local * pt_avg;
        source = bsxfun(@minus, rotation_local * source, translation_local);

        rotation = rotation * rotation_local;
        translation = rotation_local * translation + translation_local;
    end
end