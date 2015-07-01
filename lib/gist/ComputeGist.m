function [gist, param] = ComputeGist(image, param)


if ~isfield(param, 'imageSize')
    param.imageSize = [size(image,1) size(image,2)];
end

param.boundaryExtension = 32; % number of pixels to pad
% Precompute filter transfert functions (only need to do this one, unless image size is changes):
param.G = createGabor(param.orientationsPerScale, param.imageSize+2*param.boundaryExtension);

% convert to gray scale
image = single(mean(image,3));

% resize and crop image to make it square
image = imresizecrop(image, param.imageSize, 'bilinear');
%img = imresize(img, param.imageSize, 'bilinear'); %jhhays

% scale intensities to be in the range [0 255]
image = image-min(image(:));
image = 255*image/max(image(:));

% Computing gist requires 1) prefilter image, 2) filter image and collect output energies
output = prefilt(image, param.fc_prefilt);
% get gist:
g = gistGabor(output, param);

gist(1,:) = g;
drawnow

end