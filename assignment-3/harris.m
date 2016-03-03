function [H, r, c] = harris(image_path, ker_len, sigma, threshold)
    img = im2double(imread(image_path));
    imgcalc = im2double(rgb2gray(imread(image_path)));


    % calculate the derivative of each pixel in the x and y direction
    % Do this by convolving with a gaussian filter

    % calculate gaussian derivative Kernel
    G = gaussian(sigma, ker_len);
    Gd = gaussianDer(G,sigma);

    % Convolve it with the image to find derivatives
    [n,m] = size(img(:,:,1));
    Derivatives = zeros(n,m,2);

    % Note this can also be done in grayscale. Yields similar results.
    % x direction for all color channels
    Derivatives(:,:,1) = conv2(imgcalc, Gd ,'same');
    Derivatives(:,:,2) = conv2(imgcalc, Gd' ,'same');

    % Calculate A, B and C
    A = conv2(G,G', Derivatives(:,: ,1) .^2, 'same');
    B = conv2(G,G', Derivatives(:,: ,2) .* Derivatives(:,: ,1), 'same');
    C = conv2(G,G',Derivatives(:,: ,2) .^2, 'same');

    % Determine the H Matrix
    H = (A.*C - B.^2) -0.04*(A + C).^2;

    % harris corner detection (using fancy matlab function for regional optima finder)
    % Also check for threshold value
    window = 25;
    mask = ones(window);
    mask(ceil((window^2)/2)) = 0;

    Filtered = ordfilt2(H, (window^2) -1, mask);
    Maxima = (H > Filtered) & (H > threshold);

    % Removing the corners found in the 'corners' of the picture
    Maxima(1:window,1:window) = 0;
    Maxima(end - window:end,1:window) = 0;
    Maxima(1:window,end - window:end) = 0;
    Maxima(end - window:end,end - window:end) = 0;

    % Find non zero values in maximum matrix
    [r,c] = find(Maxima);


    % --------- PLOT -----------
    figure;
    subplot(2,2,1);
    imshow(img);
    hold on ;
    plot(c,r, 'bo');
    title('Corners');

    subplot(2,2,2);
    imshow(100 * Derivatives(:,: ,1));
    title('Derivatives in the X direction');


    subplot(2,2,3);
    imshow(100 * Derivatives(:,: ,2));
    title('Derivatives in the Y direction');

    subplot(2,2,4);
    imshow(img);
    title('Original Image');
end
