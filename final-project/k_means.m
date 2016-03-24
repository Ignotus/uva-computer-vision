% function K-means
% Authors: Riaan Zoetmulder & Minh Ngo

function [centroids, assignments] = k_means(descriptor_vector, num_centroids)

% normalize the descriptor vectors
normalized_descriptors = normalize(descriptor_vector)

% Run K-Means
[centroids, assignments]=vl_kmeans(normalized_descriptors, num_centroids)

end

% Function to normalize the features
function norm_matrix = normalize(mat)

    colNorms = sqrt(sum(mat.^2, 1))
    norm_matrix = bsxfun(@rdivide, mat,colNorms)

end

