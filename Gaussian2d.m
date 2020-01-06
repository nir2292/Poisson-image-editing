function g = Gaussian2d(S, sigma)
%GAUSSIAN2D S is the size of the grid and sigma is the gaussian parameter

N = max(S);
[x y] = meshgrid(round(-N/2):(round(N/2)-1), round(-N/2):(round(N/2)-1));
f = exp(-x.^2/(2*sigma^2)-y.^2/(2*sigma^2));
f = f ./ sum(f(:));
f = f - min(min(f));
f = f ./ max(max(f));
 
g = f((round(N/2)-round(S(1)/2)+1):(round(N/2)-round(S(1)/2)+S(1)), ...
      (round(N/2)-round(S(2)/2)+1):(round(N/2)-round(S(2)/2)+S(2)));

end