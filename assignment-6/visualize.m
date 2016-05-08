function visualize(points, C)
    x = points(1,:)';
    y = points(2,:)';
    z = points(3,:)';

    figure;
    fscatter3(x, y, z, C');
end