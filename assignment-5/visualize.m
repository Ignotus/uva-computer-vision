function visualize(points, color)
    if nargin < 2
        color = 'b';
    end
    if size(points, 2) > 20000
        points = points(:, randsample(size(points, 2), 20000));
    end

    x = points(1, :);
    y = points(2, :);
    z = points(3, :);
    
    xlabel('x')
    ylabel('y')
    zlabel('z')

    scatter3(x, y, z, color);
end