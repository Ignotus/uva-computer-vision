% Feature extraction
% Authors: Riaan Zoetmulder & Minh Ngo

function descriptors = feature_extraction(path, type, kp_or_dense, step_size, bin_size)
    if nargin < 3
        step_size = 8;
    end
    
    if nargin < 4
        bin_size = 3;
    end

    if strcmp(type, 'gray')
        descriptors = GrayscaleSIFT(path, kp_or_dense, step_size, bin_size);

    elseif strcmp(type,'RGB')
        descriptors = RGBSIFT(path, kp_or_dense, step_size, bin_size);

    elseif strcmp(type, 'rgb')
        descriptors = rgbSIFT(path, kp_or_dense, step_size, bin_size);

    elseif strcmp(type, 'opponent')
        descriptors = opponentSIFT(path, kp_or_dense, step_size, bin_size);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% SIFT DESCRIPTORS %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function desc = GrayscaleSIFT(path, kp_or_dense, step_size, bin_size)
    
    % Check the size of the image
    im = imread(path);
    if size(im, 3) > 2
        im = im2single(rgb2gray(im));
    else
        im = im2single(im);
    end
    
    if strcmp(kp_or_dense, 'kp')
        [~, desc] = vl_sift(im);
          
    elseif strcmp(kp_or_dense, 'dense')
        [~, desc] = vl_dsift(im, 'step', step_size, 'size', bin_size);
        
    end 
   
end

function desc = channel_sift(im, kp_or_dense, step_size, bin_size)
    if strcmp(kp_or_dense, 'kp')
        if size(im,3) > 2
            grayscale = im2single(rgb2gray(im));
            [keypoints, ~] = vl_sift(grayscale);
             
            [~, red] = vl_sift(im(:,:,1), 'frames', keypoints);
            [~, green] = vl_sift(im(:,:,2), 'frames', keypoints);
            [~, blue] = vl_sift(im(:,:,3), 'frames', keypoints);

            RG = horzcat(red, green);
            desc = horzcat( RG, blue);
        else
            [~, gray] = vl_sift(im(:,:,1));
            RG = cat(1, gray, gray);
            desc = cat(1, RG, gray);
        end
    else % Dense
        if size(im,3) > 2
            [~, red] = vl_dsift(im(:,:,1), 'step', step_size, 'size', bin_size);
            [~, green] = vl_dsift(im(:,:,2), 'step', step_size, 'size', bin_size);
            [~, blue] = vl_dsift(im(:,:,3), 'step', step_size, 'size', bin_size);
            
            RG = cat(1, red, green);
            desc = cat(1, RG, blue);
        else
            [~, gray] = vl_dsift(im(:,:,1), 'step', step_size, 'size', bin_size);
            RG = cat(1, gray, gray);
            desc = cat(1, RG, gray);
        end
    end 
end

% TODO: Check if this is the correct implementation of RGB sift, just
% concatenated the features of all channels after eachother

function desc = RGBSIFT(path, kp_or_dense, step_size, bin_size)
    im = im2single(imread(path));
    desc = channel_sift(im, kp_or_dense, step_size, bin_size);
end

function desc = rgbSIFT(path, kp_or_dense, step_size, bin_size)
    im = imread(path);
    if size(im,3) > 2
        im = im2single(normalized_rgb(im));
    else
        im = im2single(im);
    end
    desc = channel_sift(im, kp_or_dense, step_size, bin_size);
end

function desc = opponentSIFT(path, kp_or_dense, step_size, bin_size)
    im = imread(path);
    if size(im,3) > 2
        im = im2single(opponent_colors(double(im)));
    else
        im = im2single(im);
    end
    desc = channel_sift(im, kp_or_dense, step_size, bin_size);
end


%{  
    Functions to transform to a variety of color spaces
%}

% For the normalized rgb values
function img = normalized_rgb(im)
    norm = im(:,:,1)+ im(:,:,2) + im(:,:,3);
    img = zeros(size(im,1),size(im,2), size(im,3));

    img(:,:,1) = im(:,:,1)./ norm;
    img(:,:,2) = im(:,:,2)./ norm;
    img(:,:,3) = im(:,:,3)./ norm;
   
end

% Function to change to opponent colors.
function img = opponent_colors(im)
    
    % Create the opponent RGB color space
    R = im(:,:,1);
    G = im(:,:,2);
    B = im(:,:,3);
    
    o1 = (R - G) / sqrt(2);
    o2 = (R + G - 2 * B) / sqrt(6);
    o3 = (R + G + B) / sqrt(3);
    
    img = zeros(size(im,1),size(im,2), size(im,3));
    
    % normalize it
    img(:,:,1) = (o1 * sqrt(2) + 255) / (2 * 255);
    img(:,:,2) = (o2 * sqrt(6) + 2 * 255) / (4 * 255);
    img(:,:,3) = (o3 * sqrt(3)) / (3 * 255);
   
end