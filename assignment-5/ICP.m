%{
ICP algorithm:

- takes: Base point cloud, target point cloud
- returns: Rotation and translation matrix
%}

function [rotation, translation] = ICP(source, target)
    
    % Step 2: Determine which points are closest.
    closest_points = zeros(1,size(source,2));
    
    % TODO: OPTIMIZE THE SHIT OUT OF THIS.
    % iterate through points in source cloud
    for x = 1:size(source,2)
        
        % temporary variables for largest eucl. distance and point location
        largest = 10000;
        smallest_dist = -5;
        
        % iterate through target point cloud
        for y = 1:size(target,2)
            
            % calculate the euclidean distance for each point
            comparison = sum((target(:,y)- source(:, x)).^2); 
            
            % if it is smaller than the last one, update.
            if largest > comparison
                largest = comparison;
                smallest_dist = y;
            end
        end
        
        % after each point, update.
        closest_points(x) = smallest_dist;
    end
    
    % Step 3: Do an SVD of matrix H
    
    target = target(:,closest_points);
    
    % calculate average centers of mass.
    ps_avg = (1.0/ size(source,2)).* sum(source,2);
    pt_avg = (1.0/ size(target,2)).* sum(target,2);
    
    % center the points by subtracting the average
    centered_source = bsxfun(@minus, source, ps_avg);
    centered_target = bsxfun(@minus, target, pt_avg);
    
    H = source* target' - (1.0/ size(source,2))*sum(source,2)*sum(target,2)';
    
    % Perform the SVD
    [U,S,V] = svd(H);
    
    rotation = U*V';
    translation = pt_avg - ps_avg;
    det(rotation)
    
end