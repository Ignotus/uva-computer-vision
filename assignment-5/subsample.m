function subsampled_matrix = subsample(X, type, lower, upper)

if strcmp(type, 'uniform')
    subsampled_matrix = X(:, randsample(size(X, 2), upper));
    
elseif strcmp(type, 'gradient')
    lower 
    upper
    
    % sort the array
    source = KDTreeSearcher(X);
    source = source.X;
    
    % convolute and calculate length of vector
    temp = zeros(size(source));
    v = [1 -1];
    
    temp(1,:) = conv(source(1,:),v, 'same');
    temp(2,:) = conv(source(2,:),v, 'same');
    temp(3,:) = conv(source(3,:),v, 'same');
    
    
    % Calculate the length of the vector, detrimine quartiles
    len = sqrt(sum(temp.^2, 1));
    lower = quantile(len,lower); 
    upper = quantile(len, upper);
    
    
    % set quartiles to 0 and find coordinates
    % of non zero coordinates
    len(len < lower | len > upper ) = 0;
    [row,col] = find(len);
    subsampled_matrix = source(:,col);
    size(subsampled_matrix)
   
end
    
end