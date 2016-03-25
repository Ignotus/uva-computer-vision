function scaled_data = scale(data, scaling_mean, scaling_std)
    scaled_data = bsxfun(@minus, data, scaling_mean);
    scaled_data = bsxfun(@rdivide, scaled_data, scaling_std);
end