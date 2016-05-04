% % Part 1.1: Normalized Eight Point Algorithm

function part1_2()

    % path to test with
    path1 = 'House/frame00000001.png';
    path2 = 'House/frame00000002.png';
    
    % Sample size
    N = 8;
    
    format long g
    % Obtain the matches. 
    [fr1,fr2,matches] = interest_points(path1, path2);
    
    % Randomly sample 8 points
    sample = datasample(matches, N, 2);
    
    % Find the coordinates of the matching points
    X_1 = fr1(1,sample(1,:));
    Y_1 = fr1(2,sample(1,:));
    
    X_2 = fr2(1,sample(2,:));
    Y_2 = fr2(2,sample(2,:));
    
    % construct the transformation
    [X_1,Y_1, T_1] =transformation_T(X_1,Y_1);
    [X_2,Y_2, T_2] =transformation_T(X_2,Y_2);
    
    % construct A matrix
    A = [];
    for i= 1:N
        A = [A;[X_1(i)*X_2(i), X_1(i)*Y_2(i), X_1(i), Y_1(i)*X_2(i), Y_1(i)*Y_2(i), Y_1(i), X_2(i), Y_2(i), 1]];
    end
    
    % Perform an SVD of A
    [U,S,V] = svd(A);
    
    % reconstruct F
    temp = V(N,:);
    F = [[temp(1) temp(2) temp(3)]; [temp(4) temp(5) temp(6)]; [temp(7) temp(8) temp(9)]];
    
    % Enforce singularity
    [U_f, D_f, V_f] = svd(F);
    D_f(size(D_f,1), size(D_f,1)) = 0 ;
    F = U_f*D_f*V_f';
    
    % Denormalization
    F = T_2'*F*T_1;
    
end