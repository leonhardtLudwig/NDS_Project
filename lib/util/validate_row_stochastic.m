function n = validate_row_stochastic(W, name, tol)
%VALIDATE_ROW_STOCHASTIC Check that W is a square row-stochastic matrix.
%
%   n = VALIDATE_ROW_STOCHASTIC(W, name) throws a descriptive error unless W
%   is square, non-negative and has unit row sums, and returns its size n.
%
%   n = VALIDATE_ROW_STOCHASTIC(W, name, tol) uses the given absolute
%   tolerance on the row sums (default 1e-10).
%
%   The error message names the worst-offending row, because in practice the
%   usual cause is a network built from raw weights that was never passed
%   through ROW_NORMALIZE.
%
%   See also IS_ROW_STOCHASTIC, ROW_NORMALIZE.

    if nargin < 2 || isempty(name)
        name = 'matrix';
    end
    if nargin < 3 || isempty(tol)
        tol = 1e-10;
    end

    n = validate_nonnegative_matrix(W, name);

    rowSums = sum(W, 2);
    [worst, idx] = max(abs(rowSums - 1));
    if worst > tol
        error('NDS:validate:notRowStochastic', ...
            ['%s must be row-stochastic (rows summing to 1). ' ...
             'Row %d sums to %.12g (deviation %.3g > tol %.3g). ' ...
             'Did you mean to call ROW_NORMALIZE first?'], ...
            name, idx, rowSums(idx), worst, tol);
    end
end
