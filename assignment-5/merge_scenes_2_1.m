function [rt, tt] = merge_scenes_2_1()
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
