function icp_1_1()
    close all
    
    n_target = [1000 2000 3000 4000 5000 6000];
    n_source = [0.01 0.02 0.04 0.08 0.16 0.32 0.64];
    target = load('target.mat');
    source = load('source.mat');
    target = target.target;
    source = source.source;
    
    figure
    hold on 
    
    i = 0;
    results = [];
    for x = n_target
        results = [];
        
        for y = n_source
            tic
            target_subsample = subsample(target, 'uniform', x);   
%             figure()
%             hold on
            source_subsample = subsample(source, 'kmeans', y, 50);

%             size(source_subsample)
            [rotation, translation, err] = ICP(source_subsample, target_subsample, 20);
            

%             scatter3(source_subsample(1,:), source_subsample(2,:), source_subsample(3,:), 'b');
%             scatter3(source(1,:), source(2,:), source(3,:), 'r');
            source = bsxfun(@plus, rotation * source, translation);
            
            temp = [x y err toc]';
            results = [results temp];
            
%             figure()
%             hold on
%             scatter3(source_subsample(1,:), source_subsample(2,:), source_subsample(3,:), 'b');
%             scatter3(source(1,:), source(2,:), source(3,:), 'r');
%             scatter3(target(1,:), target(2,:), target(3,:), 'g');
%             hold off
%             xlabel('x');
%             ylabel('y');
%             zlabel('z');
        end
        size(results)
        
        plot(results(2, :),results(4, :),'MarkerFaceColor', [0.1*i,0.1*i, 0.1*i] )
        ylabel('Time')
        xlabel('samples taken from source cloud')
        i = i + 1;
    end
    legend('1000', '2000', '3000', '4000', '5000', '6000')
  
end