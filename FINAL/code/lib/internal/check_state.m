function x0 = check_state(x0, n)
%CHECK_STATE Verify an initial-opinion argument and return it column-wise.
%
%   x0 = CHECK_STATE(x0, n) accepts an n-vector (scalar opinions), a scalar
%   (replicated), or an n-by-m matrix (vector opinions), and returns it with
%   one row per agent.
%
%   See also CHECK_SQUARE, CHECK_VECTOR.

    if ~isnumeric(x0) || ~isreal(x0) || ~all(isfinite(x0(:)))
        error('NDS:check:notFinite', 'x0 must be real and finite.');
    end
    if isscalar(x0)
        x0 = repmat(double(x0), n, 1);
        return;
    end
    if isvector(x0) && numel(x0) == n
        x0 = double(x0(:));
        return;
    end
    if size(x0, 1) ~= n
        error('NDS:check:badLength', ...
            'x0 must have one row per agent: expected %d rows, got %d.', ...
            n, size(x0, 1));
    end
    x0 = double(x0);
end
