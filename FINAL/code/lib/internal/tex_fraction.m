function s = tex_fraction(t)
%TEX_FRACTION LaTeX text for the values of t used in the figure titles.
%
%   s = TEX_FRACTION(t) returns '1/2' for t = 0.5 and the plain %g form
%   otherwise, so that the titles read "t = 0", "t = 1/2", "t = 1".

    if abs(t - 0.5) < eps
        s = '1/2';
    else
        s = sprintf('%g', t);
    end
end
