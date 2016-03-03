function G = gaussian(sigma, kernelLength)
    % generate a vector of evenly spaced values
    X = linspace(- kernelLength / 2, kernelLength/2, kernelLength);

    % generate the kernel
    G = (1/(sigma * sqrt(2*pi)))* exp(- ((X .^ 2)/(2*sigma^2))); 
end

