function G = gaussian(sigma, kernelLength)
    radius = round(kernelLength / 2);
    G = zeros(kernelLength, 1);
    coef = 1 / (sigma * sqrt(2 * pi));
    
    if mod(kernelLength, 2) == 1
        G(radius +1, 1) = coef;
        for x=1:radius
            G(x + radius + 1, 1) = coef * exp(-x^2 / (2.0 * sigma^2));
            G(radius + 1 - x, 1) = G(x + radius + 1, 1);
        end
    else
        for x=1:radius
            %% We assume that a "point" between two central pixels is 0
            G(x + radius, 1) = coef * exp(-(x - 0.5)^2 / (2.0 * sigma^2));
            G(radius + 1 - x, 1) = G(x + radius, 1);
        end
    end
    
    %% the difference between our implementation and fspecial is that
    %% it contains a normalization parameter 
    %% in addition, our implementation is for 1D, their is for 2D
end

