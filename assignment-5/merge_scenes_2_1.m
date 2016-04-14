function [rt, tt, amse] = merge_scenes_2_1()
    amse = [];
    rt = zeros(99, 3, 3);
    tt = zeros(99, 3, 1);
    nframes = 99;
    step_size = 1;
    frame_indexes = step_size:step_size:nframes;
    mse = zeros(99, 1);

    for i=frame_indexes
        i - step_size
        tfr = frame(i - step_size);
        fr = frame(i);

        subsampled_target_frame = tfr(:, randsample(size(tfr, 2), 2000));
        subsampled_frame = fr(:, randsample(size(fr, 2), 2000));
        [rotation, translation, mse(i)] = ICP(subsampled_frame, subsampled_target_frame, 40);
        rt(i,:,:) = rotation;
        tt(i,:,:) = translation;
    end

    mse = sum(mse) / size(frame_indexes, 2)
    amse = [amse mse];

    merged_points = frame(0);

    C = ones(1, size(merged_points, 2));
    rotation = eye(3, 3);
    translation = zeros(3, 1);
    for i=frame_indexes
        R = squeeze(rt(i,:,:));
        t = tt(i,:,:)';
        rotation = R * rotation;
        translation = bsxfun(@plus, R * translation, t);

        fr = frame(i);
        fr = bsxfun(@plus, rotation * fr, translation);

        %visualize(merged_points);
        sample = randsample(size(fr, 2), 1000);
        merged_points = [merged_points fr(:, sample)];
        C = [C ones(1, 1000) * i];
    end

    visualize(merged_points, C);
end
