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