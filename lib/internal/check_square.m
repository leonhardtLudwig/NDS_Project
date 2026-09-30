function n = check_square(M, name)
%CHECK_SQUARE Verify a matrix argument and return its size.
%
%   n = CHECK_SQUARE(M, name) errors unless M is a real, finite, square
%   numeric matrix, and returns n = size(M,1).
%
%   One of three small input checks shared by the models. They exist only to
%   turn a silent dimension bug into a clear message; they perform no
%   mathematics.
%
%   See also CHECK_VECTOR, CHECK_STATE.

    if ~isnumeric(M) || ~isreal(M) || ~ismatrix(M) || size(M,1) ~= size(M,2)
        error('NDS:check:notSquare', '%s must be a real square matrix.', name);
    end
    if isempty(M) || ~all(isfinite(M(:)))
        error('NDS:check:notFinite', '%s must be non-empty and finite.', name);
    end
    n = size(M, 1);
end
