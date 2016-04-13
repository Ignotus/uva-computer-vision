% Assignment 1: CV-2
% Authors: Minh Ngo and Riaan Zoetmulder

function main()
    merge_scenes_2_1()
    %merge_scenes_2_2()
    %icp_test()
end

function icp_test()
    target = load('target.mat');
    source = load('source.mat');
    target = target.target;
    source = source.source;
    
    figure
    hold on
    
    % TODO: Plot subsample size relation / MSE:
    % - uniform subsampling
    % - random subsampling
    % - subsampling more from informative region (Yaaay! Let's do KMeans
    %   before, dude.
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

function merge_scenes_2_1()
    rt = zeros(99, 3, 3);
    tt = zeros(99, 3, 1);
    nframes = 99;
    step_size = 3;
    frame_indexes = step_size:step_size:nframes;
    for i=frame_indexes
        tfr = frame(i - step_size);
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
    for i=frame_indexes
        R = squeeze(rt(i,:,:));
        t = tt(i,:,:)';
        rotation = R * rotation;
        translation = bsxfun(@plus, R * translation, t);

        fr = frame(i);
        fr = bsxfun(@plus, rotation * fr, translation);

        merged_points = [merged_points fr];
    end

    % TODO: Visualize points from different frames in different colors!
    visualize(merged_points);
end

function merge_scenes_2_2()
    merged_points = frame(0);
    nframes = 99;
    step_size = 3;
    frame_indexes = step_size:step_size:nframes;
    for i=frame_indexes
        subsampled_target_frame = merged_points(:, randsample(size(merged_points, 2), 2500));
        fr = frame(i);
        subsampled_frame = fr(:, randsample(size(fr, 2), 2500));
        [rotation, translation, err] = ICP(subsampled_frame, subsampled_target_frame, 30, true);

        fr = bsxfun(@plus, rotation * fr, translation);
        merged_points = [merged_points fr];
    end

    visualize(merged_points);
end

function visualize(points)
    points = points(:, randsample(size(points, 2), 20000));

    x = points(1, :);
    y = points(2, :);
    z = points(3, :);

    scatter3(x, y, z, 'b');
end