% Quantization & Turning into historgrams
% Authors: Riaan & Minh

function [h] = quantize(centroids, datapoints)

% ensure the data is normalized
normalized_data = normalize(datapoints);
index =zeros(1,size(normalized_data,2));

% iterate through the data and find the closest point
for x = 1: size(normalized_data,2)
    [~,k] = min(vl_alldist(normalized_data(:,x), centroids));
    index(1,x) = k;
    
end

% return the histogram
h = histogram(index, size(centroids,2), 'Normalization', 'probability');

end

% Function to normalize the features
function norm_matrix = normalize(mat)

    colNorms = sqrt(sum(mat.^2, 1));
    norm_matrix = bsxfun(@rdivide, mat,colNorms);

end
