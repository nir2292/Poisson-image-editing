function guidance_field = SpecialGuidanceB(source, target, mask, offset, alpha)
%SPECIALGUIDANCEB creates a custom guidance field for the cloning process

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

% blend two guidance fields using a custom gaussian that depends on
% distance from edge
gauss3by3 = 1/16 * [[1 2 1];[2 4 2];[1 2 1]];
characFunc = conv2(double(mask),gauss3by3,'same');
characFunc(characFunc>0.5)=0;
characFunc(characFunc<0.1)=0;
characFunc(characFunc>0)=1;
B = 1 ./ ((double(bwdist(characFunc))+1e-2) .^ alpha);
B = B - min(min(B));
B = B ./ max(max(B));
guidance_field = guidanceField_s .* (1 - B) + guidanceField_t .* B;

end

