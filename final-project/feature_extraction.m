% Feature extraction
% Authors: Riaan Zoetmulder & Minh Ngo

function descriptors = feature_extraction(path, type, kp_or_dense)


    if strcmp(type, 'gray')
        descriptors = GrayscaleSIFT(path, kp_or_dense);

    elseif strcmp(type,'RGB')
        descriptors = RGBSIFT(path, kp_or_dense);

    elseif strcmp(type, 'rgb')
        descriptors = rgbSIFT(path, kp_or_dense);

    elseif strcmp(type, 'opponent')
        descriptors = opponentSIFT(path, kp_or_dense);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% SIFT DESCRIPTORS %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function desc = GrayscaleSIFT(path, kp_or_dense)
    
    % Check the size of the image
    im = imread(path);
    if size(im, 3) > 2
        im = im2single(rgb2gray(im));
    else
        im = im2single(im)
    end
    
    if strcmp(kp_or_dense, 'kp')
        [feat, desc] = vl_sift(im);
          
    elseif strcmp(kp_or_dense, 'dense')
        [feat, desc] = vl_dsift(im);
        
    end 
   
end

% TODO: Check if this is the correct implementation of RGB sift, just
% concatenated the features of all channels after eachother

function desc = RGBSIFT(path, kp_or_dense)
    im = im2single(imread(path));
    
    if strcmp(kp_or_dense, 'kp')
        [feat, red] = vl_sift(im(:,:,1));
        [feat, green] = vl_sift(im(:,:,2));
        [feat, blue] = vl_sift(im(:,:,3));
        
        RG = cat(2, red, green);
        desc = cat(2, RG, blue);
          
    elseif strcmp(kp_or_dense, 'dense')
        [feat, red] = vl_dsift(im(:,:,1));
        [feat, green] = vl_dsift(im(:,:,2));
        [feat, blue] = vl_dsift(im(:,:,3));
        
        RG = cat(2, red, green);
        desc = cat(2, RG, blue);
       
    end 

end

function feat = rgbSIFT(path, kp_or_dense)
    im = im2single(normalized_rgb(imread(path)));
    
    if strcmp(kp_or_dense, 'kp')
        [feat, red] = vl_sift(im(:,:,1));
        [feat, green] = vl_sift(im(:,:,2));
        [feat, blue] = vl_sift(im(:,:,3));
        
        RG = cat(2, red, green);
        desc = cat(2, RG, blue);
          
    elseif strcmp(kp_or_dense, 'dense')
        [feat, red] = vl_dsift(im(:,:,1));
        [feat, green] = vl_dsift(im(:,:,2));
        [feat, blue] = vl_dsift(im(:,:,3));
        
        RG = cat(2, red, green);
        desc = cat(2, RG, blue);
       
    end 
    
end

function feat = opponentSIFT(path, kp_or_dense)

    im = im2single(opponent_colors(double(imread(path))));
    
    if strcmp(kp_or_dense, 'kp')
        [feat, red] = vl_sift(im(:,:,1));
        [feat, green] = vl_sift(im(:,:,2));
        [feat, blue] = vl_sift(im(:,:,3));
        
        RG = cat(2, red, green);
        desc = cat(2, RG, blue);
          
    elseif strcmp(kp_or_dense, 'dense')
        [feat, red] = vl_dsift(im(:,:,1));
        [feat, green] = vl_dsift(im(:,:,2));
        [feat, blue] = vl_dsift(im(:,:,3));
        
        RG = cat(2, red, green);
        desc = cat(2, RG, blue);
       
    end 
    figure
    image(im)
    
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