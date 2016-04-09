% Assignment 1: CV-2
% Authors: Minh Ngo and Riaan Zoetmulder

function main()
    merge_scenes()
    %icp_test()
end

function icp_test()
    target = load('target.mat');
    source = load('source.mat');
    target = target.target;
    source = source.source;
    
    figure
    hold on
    
    [rotation, translation, matches, err] = ICP(source, target, 20);
    source = bsxfun(@minus, rotation * source, translation);

    scatter3(source(1,:), source(2,:), source(3,:), 'b');
    scatter3(target(1,:), target(2,:), target(3,:), 'g');

    hold off
end

function points = frame(id)
    points = readPcd(sprintf('data/%010d.pcd', id));
    points = points(:,1:3)';
end

function merge_scenes()
    merged_points = frame(0);
    size(merged_points)
    for i=1:99
        subsampled_merged = merged_points(:, randsample(size(merged_points, 2), 6400));
        fr = frame(i);
        subsampled_frame = fr(:, randsample(size(fr, 2), 6400));
        [rotation, translation, matches, err] = ICP(subsampled_frame, subsampled_merged, 20);
        fr = bsxfun(@minus, rotation * fr, translation);

        merged_points = [merged_points(:, matches == 0) fr];
    end

    scatter3(merged_points(1,:), merged_points(2,:), merged_points(3,:), 'b');
end