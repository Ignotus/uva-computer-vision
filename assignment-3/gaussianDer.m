function Gd = gaussianDer(G, sigma)
    % determine the size of the kernel
    sz = length(G);
    X = linspace(-sz/2, sz/2, sz);
    
    % calculate the Gaussian Derivative
    Gd = (-X/(sigma^2)).*G;
end