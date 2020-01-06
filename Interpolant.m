function w = Interpolant(maskSize)
%INTERPOLANT interpolant as described in 'Convolution Pyramids, by Farbman et al. 2011'

distMask = zeros(maskSize);
sizeW = size(distMask);
distMask(floor(sizeW(1)/2), floor(sizeW(2)/2)) = 1;
zeroDivFactor = 1e-1;
w = 1 ./ ((double(bwdist(distMask))+zeroDivFactor) .^ 3);
    
end