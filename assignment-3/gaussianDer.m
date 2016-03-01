function [Gd] = gaussianDer(G, sigma)
    [w, ~] = size(G);
    Gd = zeros(w, 1);
    radius = floor(w / 2);
    for x=1:w
        Gd(x, 1) = - (radius + 1 - x) / (sigma^2) * G(x, 1);
    end
end