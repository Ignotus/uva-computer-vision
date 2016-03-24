% Quantization & Turning into historgrams
% Authors: Riaan & Minh

function [h] = quantize(centroids, datapoints)

normalized_data = normalize(datapoints);

index =[];
for x = 1: size(normalized_data,2)
    [~, k] = min(vl_alldist2(normalized_data, centroids));
    [index ; k];
    
end

h = histogram(index, size(centroids,2), 'Normalization', probability);

end

% Function to normalize the features
function norm_matrix = normalize(mat)

    colNorms = sqrt(sum(mat.^2, 1));
    norm_matrix = bsxfun(@rdivide, mat,colNorms);

end
