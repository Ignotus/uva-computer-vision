% Assignment 1: CV-2
% Authors: Minh Ngo and Riaan Zoetmulder

function main()
    target = load('target.mat');
    source = load('source.mat');
    target = target.target;
    source = source.source;
    
    rotation = eye(3);
    translation = zeros(3,1);
    
    
    for x = 1:20

        [rotation, translation] = ICP(source, target)
        source = bsxfun(@plus,rotation*source,translation);
        %scatter3(source(1,:),source(2,:),source(3,:),'b')
        
    end
    figure
    scatter3(source(1,:),source(2,:),source(3,:),'b')
    hold on 
    scatter3(target(1,:),target(2,:),target(3,:),'r')
    
    hold off
    
    
    %hold on
    
    %scatter3(source(1,:),source(2,:), source(3,:),'g')
    
    %hold off
end
