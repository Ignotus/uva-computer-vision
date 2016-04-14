function points = frame(id)
    points = readPcd(sprintf('data/%010d.pcd', id));
    points = points(:,1:3)';
    points = points(:, points(3,:) < 1.9);
end