function s = format_eigenvalues(e)
%FORMAT_EIGENVALUES Eigenvalue list as text, 4 decimals.
%
%   s = FORMAT_EIGENVALUES(e) returns the eigenvalues as a single string,
%   separated by two spaces, with the real ones printed without the "+0i"
%   tail.
%
%   See also SORT_EIGENVALUES.

    parts = cell(1, numel(e));
    for k = 1:numel(e)
        if abs(imag(e(k))) < 1e-10
            parts{k} = sprintf('%.4f', real(e(k)));
        else
            parts{k} = sprintf('%.4f%+.4fi', real(e(k)), imag(e(k)));
        end
    end
    s = strjoin(parts, '  ');
end
