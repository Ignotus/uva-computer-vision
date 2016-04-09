% Assignment 1: CV-2
% Authors: Minh Ngo and Riaan Zoetmulder

function main()
    target = load('target.mat');
    source = load('source.mat');
    target = target.target;
    source = source.source;
    
    figure
    hold on
    
    [rotation, translation, err] = ICP(source, target, 20);
    source = bsxfun(@minus, rotation * source, translation);
    
    scatter3(source(1,:), source(2,:), source(3,:), 'b');
    scatter3(target(1,:), target(2,:), target(3,:), 'g');
    
    hold off
end
