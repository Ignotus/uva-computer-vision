function im = frame(id, teddy)

if teddy
    im = imread(sprintf('TeddyBear/obj02_%03d.png', id));
else
    im = imread(sprintf('House/frame%08d.png', id));
end

if length(size(im)) == 3
    im = rgb2gray(im);
end

im = im2single(im);