function v = diagonal_parameter(P, n, name, lo, hi)
%DIAGONAL_PARAMETER Normalise a diagonal model parameter to a column vector.
%
%   v = DIAGONAL_PARAMETER(P, n, name, lo, hi) accepts the several shapes in
%   which a diagonal parameter may reasonably be supplied and returns the
%   canonical n-by-1 column vector.
%
%   Accepted inputs
%       []                     -> zeros(n,1)
%       scalar                 -> replicated to all n agents
%       n-element vector       -> used as is
%       n-by-n diagonal matrix -> its diagonal
%
%   lo and hi bound the admissible values (use -Inf / Inf for unbounded).
%
%   This is shared by the susceptibility matrix Lambda of the
%   Friedkin-Johnsen model (bounded in [0,1]) and the prejudice-rate matrix
%   Gamma of the Taylor model (bounded in [0,Inf)), so the two never drift
%   apart in how they validate their inputs.
%
%   See also FJ_MATRICES, TAYLOR_MATRICES, FJ_LAMBDA.

    narginchk(3, 5);
    if nargin < 4 || isempty(lo)
        lo = -Inf;
    end
    if nargin < 5 || isempty(hi)
        hi = Inf;
    end

    if isempty(P)
        v = zeros(n, 1);
        return;
    end

    if ~isnumeric(P) || ~isreal(P)
        error('NDS:diagonalParameter:notRealNumeric', ...
            '%s must be a real numeric scalar, vector or diagonal matrix.', name);
    end

    if isscalar(P)
        v = repmat(double(P), n, 1);
    elseif isvector(P) && numel(P) == n
        v = double(P(:));
    elseif ismatrix(P) && size(P, 1) == n && size(P, 2) == n
        offDiagonal = P - diag(diag(P));
        if any(abs(offDiagonal(:)) > 0)
            error('NDS:diagonalParameter:notDiagonal', ...
                ['%s must be DIAGONAL (or a vector of its diagonal entries); ' ...
                 'found a non-zero off-diagonal entry.'], name);
        end
        v = double(diag(P));
    else
        error('NDS:diagonalParameter:sizeMismatch', ...
            ['%s must be a scalar, an %d-element vector, or an %d-by-%d ' ...
             'diagonal matrix (got %s).'], name, n, n, n, mat2str(size(P)));
    end

    if ~all(isfinite(v))
        error('NDS:diagonalParameter:notFinite', ...
            '%s must contain only finite values.', name);
    end
    if any(v < lo) || any(v > hi)
        error('NDS:diagonalParameter:outOfRange', ...
            '%s must lie in [%g, %g]; found values in [%g, %g].', ...
            name, lo, hi, min(v), max(v));
    end
end
