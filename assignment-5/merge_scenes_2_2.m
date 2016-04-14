function merge_scenes_2_2()
    merged_points = frame(0);

    nframes = 99;
    step_size = 3;
    frame_indexes = step_size:step_size:nframes;
    for i=frame_indexes
        subsampled_target_frame = merged_points(:, randsample(size(merged_points, 2), 1000));

        fr = frame(i);
        subsampled_frame = fr(:, randsample(size(fr, 2), 1000));

        [rotation, translation, mse] = ICP(subsampled_frame, subsampled_target_frame, 20);

        fr = bsxfun(@plus, rotation * fr, translation);
        merged_points = [merged_points fr];

    end

    visualize(merged_points);
end
