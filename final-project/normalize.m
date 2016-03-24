
% Function to normalize the features
function norm_matrix = normalize(mat)

    colNorms = sqrt(sum(mat.^2, 1));
    norm_matrix = bsxfun(@rdivide, mat,colNorms);

end