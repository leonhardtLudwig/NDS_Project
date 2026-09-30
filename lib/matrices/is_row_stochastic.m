function tf = is_row_stochastic(W, tol)
%IS_ROW_STOCHASTIC True when W is non-negative with unit row sums.
%
%   tf = IS_ROW_STOCHASTIC(W) tests whether W is a stochastic matrix, within
%   an absolute tolerance of 1e-10 on the row sums.
%
%   tf = IS_ROW_STOCHASTIC(W, tol) uses the given tolerance.
%
%   See also ROW_STOCHASTIC.

    if nargin < 2, tol = 1e-10; end

    tf = isnumeric(W) && ismatrix(W) && ~isempty(W) && ...
         all(W(:) >= 0) && max(abs(sum(W, 2) - 1)) <= tol;
end
