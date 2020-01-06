function guidance_field = SpecialGuidanceA(source, target, mask, offset, alpha)
%SPECIALGUIDANCEA creates a custom guidance field for the cloning process

% create guidance field of source
guidanceFieldMask = [0 -1 0; -1 4 -1; 0 -1 0];
padded_source = [source(1, :); source; source(end, :)];
padded_source = [padded_source(:, 1) ,padded_source ,padded_source(:, end)];
guidanceField_s = conv2(padded_source, guidanceFieldMask, 'same');
guidanceField_s = guidanceField_s(2:(end-1), 2:(end-1));

% create guidance field of target behind the source's location
s = size(source);
target_cropped = target(offset(1):(offset(1)+s(1)-1), offset(2):(offset(2)+s(2)-1));
padded_target = [target_cropped(1, :); target_cropped; target_cropped(end, :)];
padded_target = [padded_target(:, 1) , padded_target, padded_target(:, end)];
guidanceField_t = conv2(padded_target, guidanceFieldMask, 'same');
guidanceField_t = guidanceField_t(2:(end-1) , 2:(end-1));

% blend two guidance fields using a gaussian
gaussKernel = Gaussian2d(size(source), alpha);
guidance_field = guidanceField_s .* gaussKernel + guidanceField_t .* (1-gaussKernel);

end

