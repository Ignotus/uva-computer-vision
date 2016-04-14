function merged_points = merge_scenes_2_2()
    merged_points = frame(0);

    nframes = 99;
    step_size = 1;
    sample_size = 1000;
    
    vis_points = merged_points(:, randsample(size(merged_points, 2), sample_size));
    
    C = ones(1, sample_size);
    frame_indexes = step_size:step_size:nframes;
    for i=frame_indexes
        subsampled_target_frame = merged_points(:, randsample(size(merged_points, 2), 5000));

        fr = frame(i);
        subsampled_frame = fr(:, randsample(size(fr, 2), sample_size));

        [rotation, translation, mse] = ICP(subsampled_frame, subsampled_target_frame, 20);

        merged_points = bsxfun(@minus, rotation' * merged_points, translation);
        merged_points = [merged_points fr];
        
        vis_points = bsxfun(@minus, rotation' * vis_points, translation);
        vis_points = [vis_points subsampled_frame];
        C = [C ones(1, sample_size) * i];
    end
    
    visualize(vis_points, C);
end
