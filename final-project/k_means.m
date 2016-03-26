% function K-means
% Authors: Riaan Zoetmulder & Minh Ngo

function [centroids, assignments] = k_means(descriptor_vector, num_centroids)

	% normalize the descriptor vectors
	normalized_descriptors = normalize(descriptor_vector);
    
    % Fix NaN
    normalized_descriptors(isnan(normalized_descriptors)) = 0 ;

	% Run K-Means
	[centroids, assignments] = vl_kmeans(normalized_descriptors, num_centroids);

end
