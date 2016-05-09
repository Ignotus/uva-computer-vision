function visualize(points, C)
    x = points(1,:)';
    y = points(2,:)';
    z = points(3,:)';

    figure;
    if nargin == 1
        C = ones(1, size(points, 2));
        C(1, end) = 10;
        fscatter3(x, y, z, C');
    else
        fscatter3(x, y, z, C');
    end
end