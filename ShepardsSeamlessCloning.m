function [ output ] = ShepardsSeamlessCloning(source, target, mask, offset, F)
%SHEPARDSSEAMLESSCLONING Performs seamless cloning of source to target
% according to the given mask and offset by using shephards interpolation

output = zeros(size(target));

output(:,:,1) = SingleChannelClone(source(:,:,1), target(:,:,1), mask, offset, F);
output(:,:,2) = SingleChannelClone(source(:,:,2), target(:,:,2), mask, offset, F);
output(:,:,3) = SingleChannelClone(source(:,:,3), target(:,:,3), mask, offset, F);

end

function [ output ] = SingleChannelClone(source, target, mask, offset, F)
%SINGLECHANNELCLONE does the above for a single channel

% find tightest rectangle containing all non-zero parts of the mask
rectCoords = GetCornersOfMask(mask);
topLeftCornerY = rectCoords(1);
topLeftCornerX = rectCoords(2);
bottomRightCornerY = rectCoords(3);
bottomRightCornerX = rectCoords(4);

% crop images to fit only relevant parts that are used from source
croppedMask = mask(topLeftCornerX:bottomRightCornerX, topLeftCornerY:bottomRightCornerY);
croppedSource = source(topLeftCornerX:bottomRightCornerX, topLeftCornerY:bottomRightCornerY);
croppedTarget = target(topLeftCornerX+offset(1):bottomRightCornerX+offset(1), ...
    topLeftCornerY+offset(2):bottomRightCornerY+offset(2));

% create a shifted mask the size of the target image
shiftedMask = zeros(size(target));
shiftedMask(topLeftCornerX+offset(1):bottomRightCornerX+offset(1), ...
            topLeftCornerY+offset(2):bottomRightCornerY+offset(2)) = ...
            mask(topLeftCornerX:bottomRightCornerX, ...
            topLeftCornerY:bottomRightCornerY);

% interpolate
w = F(size(croppedMask));
gauss3by3 = 1/16 * [[1 2 1];[2 4 2];[1 2 1]];

characFunc = conv2(double(croppedMask), gauss3by3, 'same');
characFunc(characFunc > 0.5) = 0;
characFunc(characFunc < 0.1) = 0;
characFunc(characFunc > 0) = 1;

rgag = (croppedTarget - croppedSource) .* characFunc;

numer = conv2(rgag, w, 'same');
denomin = conv2(characFunc, w, 'same');
res = (numer ./ denomin) + croppedSource;

interpolated = zeros(size(target));
interpolated(topLeftCornerX+offset(1):bottomRightCornerX+offset(1), ...
    topLeftCornerY+offset(2):bottomRightCornerY+offset(2)) = res;

output = target .* ~shiftedMask + interpolated .* shiftedMask;

end