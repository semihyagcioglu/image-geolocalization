function feature_vector = ComputeTinyImage(image, width, height)

if nargin<3
    % Default parameters
    width = 32;
    height = 32;
end

image = single(imresize(image, [width height]));
image = image(:);
feature_vector = image;

clear image width height;

end