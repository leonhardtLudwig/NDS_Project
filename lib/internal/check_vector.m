function v = check_vector(v, n, name)
%CHECK_VECTOR Verify an n-vector argument and return it as a column.
%
%   v = CHECK_VECTOR(v, n, name) errors unless v is a real finite vector with
%   n elements (a scalar is accepted and replicated), and returns a column.
%
%   See also CHECK_SQUARE, CHECK_STATE.

    if ~isnumeric(v) || ~isreal(v) || ~all(isfinite(v(:)))
        error('NDS:check:notFinite', '%s must be real and finite.', name);
    end
    if isscalar(v)
        v = repmat(double(v), n, 1);
        return;
    end
    if ~isvector(v) || numel(v) ~= n
        error('NDS:check:badLength', ...
            '%s must have %d elements (got %d).', name, n, numel(v));
    end
    v = double(v(:));
end
