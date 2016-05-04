% Transformation_T
%{
Input: X_points, Y points (row vectors) 
Output: transformed; X and Y Points
%}

function [X_points, Y_points, T] = transformation_T(X,Y)
    
    % calculate means and standard deviation
    N = size(X,2);
    v = ones(1,N)';
    m_x = (1/N)*X*v; 
    m_y = (1/N)*Y*v;
    d = (1/N)* ((((X - m_x).^2 + (Y - m_y).^2)*v)^(1/2));
    
    % construct the matrix T
    T = [[(2^(1/2))/d 0 -m_x*(2^(1/2))/d];[0 (2^(1/2))/d  -m_y*(2^(1/2))/d];[0 0 1]];
    
    % transform points.
    U = vertcat(vertcat(X,Y), ones(1,N));
    
    U = T*U;
    
    X_points= U(1,:);
    Y_points = U(2,:);
end