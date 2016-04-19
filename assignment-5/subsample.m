function subsampled_matrix = subsample(X, type, upper, ncentroids)

if nargin == 3
    ncentroids = 50;
end

if strcmp(type, 'uniform')
    subsampled_matrix = X(:, randsample(size(X, 2), upper));
    
elseif strcmp(type, 'kmeans')
    X_mean = mean(X, 2);
    X_std = std(X, [], 2);
    
    X_scaled = scale(X, X_mean, X_std);

    [centroids, assignments] = vl_kmeans(X_scaled, ncentroids);
    
%      size(centroids)
%      size(X_std)
%      centroids = bsxfun(@plus, centroids', X_std);
%      centroids = bsxfun(@times, centroids, X_mean);
%     
%      scatter3(centroids(1,:), centroids(2,:), centroids(3,:), 'b');
    subsampled_matrix = [];
    for idx=1:200
        assignment = X(:, assignments == idx);
        subsampled_matrix = [subsampled_matrix assignment(:, randsample(size(assignment, 2), round(size(assignment, 2) * upper)))];
    end
end
   

end

function scaled_data = scale(data, scaling_mean, scaling_std)
    scaled_data = bsxfun(@minus, data, scaling_mean);
    scaled_data = bsxfun(@rdivide, scaled_data, scaling_std);
end