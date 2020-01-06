function [ output ] = CustomSeamlessCloning(source, target, mask, offset, G)
%CUSTOMSEAMLESSCLONING Performs seamless cloning of source to target
% according to the given mask and offset by solving a laplace equation with
% a custom guidance field that blends the gradients of the source and
% target

output = zeros(size(target));

output(:,:,1) = SingleChannelClone(source(:,:,1), target(:,:,1), mask, offset, G);
output(:,:,2) = SingleChannelClone(source(:,:,2), target(:,:,2), mask, offset, G);
output(:,:,3) = SingleChannelClone(source(:,:,3), target(:,:,3), mask, offset, G);

end

function [ output ] = SingleChannelClone(source, target, mask, offset, G)
%SINGLECHANNELCLONE does the above for a single channel

% find tightest rectangle containing all non-zero parts of the mask
rectCoords = GetCornersOfMask(mask);
topLeftCornerY = rectCoords(1);
topLeftCornerX = rectCoords(2);
bottomRightCornerY = rectCoords(3);
bottomRightCornerX = rectCoords(4);

% create guidance field
guidanceField = G(source, target, mask, offset, 0.01);

% image the size of target with the guidance field shifted by the offset
shiftedGuidanceField = zeros(size(target));
shiftedGuidanceField(topLeftCornerX+offset(1):bottomRightCornerX+offset(1), ...
              topLeftCornerY+offset(2):bottomRightCornerY+offset(2)) = ...
              guidanceField(topLeftCornerX:bottomRightCornerX, ...
              topLeftCornerY:bottomRightCornerY);

% shifted mask the size of the target image
shiftedMask = zeros(size(target));
shiftedMask(topLeftCornerX+offset(1):bottomRightCornerX+offset(1), ...
            topLeftCornerY+offset(2):bottomRightCornerY+offset(2)) = ...
            mask(topLeftCornerX:bottomRightCornerX, ...
            topLeftCornerY:bottomRightCornerY);

% create matrix of linear equations to solve
mapSource = find(shiftedMask);
mapTarget = find(~shiftedMask);
neighAbove = mapSource - 1;
neighBelow = mapSource + 1;
neighRight = mapSource + size(shiftedMask,1);
neighLeft = mapSource - size(shiftedMask,1);
A = ones(size(mapSource));
pixat_mask_avg_neigh = [...
    mapSource  mapSource         4.00*A
    mapSource  neighAbove  -1.00*A
    mapSource  neighRight   -1.00*A
    mapSource  neighBelow  -1.00*A
    mapSource  neighLeft   -1.00*A ];
pixat_background = [mapTarget  mapTarget  1.00*ones(size(mapTarget))];
sparseRep = [pixat_mask_avg_neigh; pixat_background];
A = sparse(sparseRep(:,1),sparseRep(:,2),sparseRep(:,3));
b = shiftedGuidanceField .* shiftedMask + target .* ~shiftedMask;
b = b(:);

% solve equations
res = A\b;
output = reshape(res, size(target));

end