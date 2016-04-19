function icp_1_1()
    close all
    
    n_target = [1000 2000 3000 4000 5000 6000];
    %n_target = [1000 2000]; 
    %n_source = [0.98 0.9 0.8 0.6 0.5 0.3 0.2 0.1 0.04 0.02];
    %n_source = [2 4 8 16 32 64 128 256 512 1024 2048 4096]
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
            target_subsample = subsample(target, 'uniform', (0.5-(y*0.5)),x);
            source_subsample = subsample(source, 'uniform', (0.5-(y*0.5)),x);
            %source_subsample = subsample(source, 'gradient', 1 - y, 1)
            [rotation, translation, err] = ICP(source_subsample, target_subsample, 20);
            source = bsxfun(@plus, rotation * source, translation);
            
            temp = [x y err toc]';
            results = [results temp];
            
            figure()
            scatter3(source(1,:), source(2,:), source(3,:), 'b');
            scatter3(target(1,:), target(2,:), target(3,:), 'g');
            xlabel('x');
            ylabel('y');
            zlabel('z');
        end
        size(results)
        plot(results(2, :),results(3, :),'MarkerFaceColor', [0.1*i,0.1*i, 0.1*i] )
        ylabel('Time')
        xlabel('samples taken from source cloud')
        i = i + 1;
    end
    legend('1000', '2000', '3000', '4000', '5000', '6000')
    
    %{
    target_subsample = target;
    source_subsample = subsample(source, 'uniform',0,6);
    [rotation, translation, err] = ICP(source_subsample, target_subsample, 20);
    source = bsxfun(@plus, rotation * source, translation);
    %}
end