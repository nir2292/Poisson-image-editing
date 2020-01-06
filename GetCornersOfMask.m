function [ coords ] = GetCornersOfMask( mask )
%GETCORNERSOFMASK finds the tightest rectangle containing all 
% non-zero parts of the mask

coords = zeros(1, 4);

% top-left corner y coordinate
[dim_rows_mask, dim_cols_mask] = size(mask);
for i = 1:dim_cols_mask
    if (max(mask(:,i)) > 0)
        coords(1) = i;
        break
    end
end

% top-left corner x coordinate
for i = 1:dim_rows_mask
    if (max(mask(i,:)) > 0)
        coords(2) = i;
        break
    end
end

% bottom-right corner y coordinate
for i = dim_cols_mask:-1:1
    if (max(mask(:,i)) > 0)
        coords(3) = i;
        break
    end
end

% bottom-right corner x coordinate
for i = dim_rows_mask:-1:1
    if (max(mask(i,:)) > 0)
        coords(4) = i;
        break
    end
end

end

