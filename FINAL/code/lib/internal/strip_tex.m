function s = strip_tex(s)
%STRIP_TEX Plain-text version of a short LaTeX label.
%
%   s = STRIP_TEX(s) removes the dollar signs and turns \to into ->, so that
%   a title written for a figure can also be printed to the command window.

    s = strrep(strrep(s, '$', ''), '\to', '->');
end
