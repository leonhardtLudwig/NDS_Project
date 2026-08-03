function [X0, d] = prepare_state(x0, n, name)
%PREPARE_STATE Normalise an initial-opinion argument to an n-by-d matrix.
%
%   [X0, d] = PREPARE_STATE(x0, n, name) accepts any of the shapes commonly
%   used for opinions and returns the canonical internal layout:
%
%       X0 : n-by-d matrix, row i holding the opinion of agent i
%       d  : opinion dimension (1 for the scalar models)
%
%   Accepted inputs:
%       n-by-1 column vector   -> scalar opinions   (d = 1)
%       1-by-n row vector      -> scalar opinions   (d = 1, transposed)
%       n-by-d matrix          -> vector opinions
%       scalar                 -> replicated to all n agents (d = 1)
%
%   The project works with scalar opinions throughout, but every simulator
%   stores trajectories as n-by-d-by-K internally so that vector-valued
%   opinions can be enabled later without rewriting the models.
%
%   See also PACK_RESULT.

    if nargin < 3 || isempty(name)
        name = 'x0';
    end

    if ~isnumeric(x0) || ~isreal(x0)
        error('NDS:validate:notRealNumeric', ...
            '%s must be a real numeric array (got %s).', name, class(x0));
    end
    if ~all(isfinite(x0(:)))
        error('NDS:validate:notFinite', ...
            '%s must contain only finite values (found Inf or NaN).', name);
    end
    if ndims(x0) > 2 %#ok<ISMAT>
        error('NDS:validate:not2D', ...
            '%s must be a vector or a 2-D matrix.', name);
    end

    if isscalar(x0) && n > 1
        X0 = repmat(x0, n, 1);
        d = 1;
        return;
    end

    if isrow(x0) && numel(x0) == n && n > 1
        % Tolerate a row vector of the right length: unambiguous and common.
        X0 = x0(:);
        d = 1;
        return;
    end

    if size(x0, 1) ~= n
        error('NDS:validate:sizeMismatch', ...
            ['%s must have one row per agent: expected %d rows, got %d-by-%d. ' ...
             'Row i holds the opinion of agent i.'], ...
            name, n, size(x0, 1), size(x0, 2));
    end

    X0 = x0;
    d = size(x0, 2);

    if d == 0
        error('NDS:validate:emptyState', '%s must have at least one column.', name);
    end
end
