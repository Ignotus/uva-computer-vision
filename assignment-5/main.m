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
    
    [rotation, translation, err] = ICP(source, target, 20);
    source = bsxfun(@plus, rotation * source, translation);

    scatter3(source(1,:), source(2,:), source(3,:), 'b');
    scatter3(target(1,:), target(2,:), target(3,:), 'g');

    hold off
end

function points = frame(id)
    points = readPcd(sprintf('data/%010d.pcd', id));
    points = points(:,1:3)';
    points = points(:, points(3,:) < 1.9);
end

function merge_scenes()
    rt = zeros(99, 3, 3);
    tt = zeros(99, 3, 1);
    nframes = 99;
    for i=1:nframes
        tfr = frame(i - 1);
        subsampled_target_frame = tfr(:, randsample(size(tfr, 2), 1000));
        fr = frame(i);
        subsampled_frame = fr(:, randsample(size(fr, 2), 1000));
        [rotation, translation, err] = ICP(subsampled_frame, subsampled_target_frame, 20);
        rt(i,:,:) = rotation;
        tt(i,:,:) = translation;
    end

    merged_points = frame(0);
    rotation = eye(3, 3);
    translation = zeros(3, 1);
    for i=1:nframes
        R = squeeze(rt(i,:,:));
        t = tt(i,:,:)';
        rotation = R * rotation;
        translation = bsxfun(@plus, R * translation, t);

        fr = frame(i);
        fr = bsxfun(@plus, rotation * fr, translation);

        merged_points = [merged_points fr];
    end

    merged_points = merged_points(:, randsample(size(merged_points, 2), 20000));

    x = merged_points(1,:);
    y = merged_points(2,:);
    z = merged_points(3,:);

    scatter3(x, y, z, 'b');
end