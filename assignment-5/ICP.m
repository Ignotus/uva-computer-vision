%{
ICP algorithm:

- takes: Base point cloud, target point cloud
- returns: Rotation and translation matrix
%}

function [rotation, translation, err] = ICP(source, target, niter, numsample)
    rotation = eye(3, 3);
    translation = zeros(3, 1);
    
    for iter=1:niter
        if nargin == 4
            target = subsample(target, 'uniform', numsample);
        end
        % Step 2: Determine which points are closest.
        closest_points = zeros(1, size(source, 2));
        min_distances = zeros(1, size(source, 2));

        % iterate through points in source cloud and find minimal distance
        % to the target point cloud
        for x = 1:size(source, 2)
            distance2 = sum(bsxfun(@minus, target, source(:, x)).^2, 1);
            [min_distances(x), closest_points(x)] = min(distance2, [], 2);
        end
        err = mean(min_distances);
        display(sprintf('MSE %.6f', err));

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

        % Bærentzen et al. (2012) "Guide to Computational Geometry
        % Processing", Chapter 15, Table 15.1.
        % det(U * V') should be +1.
        R = V * diag([1 1 det(U*V')]) * U';

        % There is a bug in  Bærentzen et al. (2012) Chapter 15, Table 15.1.
        % Rotation matrix is missing.
        %
        % Following the original paper Bels et al. (1993) "A Method for
        % Registration of 3-D Shapes", formula (26) instead.
        t = pt_avg - R * ps_avg;
        source = bsxfun(@plus, R * source, t);

        rotation = R * rotation;
        translation = R * translation + t;
    end
end