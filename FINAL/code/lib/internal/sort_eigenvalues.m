function e = sort_eigenvalues(e)
%SORT_EIGENVALUES Deterministic ordering of an eigenvalue list.
%
%   e = SORT_EIGENVALUES(e) returns the eigenvalues sorted by decreasing real
%   part and then by decreasing imaginary part, both rounded to 6 decimals
%   before comparing, so that two runs that differ only by round-off produce
%   the same order.
%
%   Used to print and compare spectra; see FORMAT_EIGENVALUES.

    e = e(:);
    [~, idx] = sortrows([-round(real(e), 6), -round(imag(e), 6)]);
    e = e(idx);
end
