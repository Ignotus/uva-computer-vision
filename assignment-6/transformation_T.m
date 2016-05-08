% Transformation_T
%{
Input: X_points, Y points (row vectors) 
Output: transformed; X and Y Points
%}

function [X_points, Y_points, T] = transformation_T(X,Y)
    % calculate means and standard deviation
    N = size(X,2);
    m_x = mean(X);
    m_y = mean(Y);
    
    d = mean(sqrt((X - m_x).^2 + (Y - m_y).^2));
    
    % construct the matrix T
    T = [sqrt(2)/d     0            -m_x*sqrt(2)/d;
         0             sqrt(2)/d    -m_y*sqrt(2)/d;
         0             0            1];
    
    % transform points.
    U = vertcat(X, Y, ones(1,N));
    
    U = T * U;
    assert(size(U, 1) == 3);
    
    X_points = U(1, :);
    Y_points = U(2, :);
    
    assert(mean(X_points) < 0.00001);
    assert(mean(Y_points) < 0.00001);
    assert(abs(mean(sqrt(X_points .^2 + Y_points .^2)) - sqrt(2)) < 0.00001);
end