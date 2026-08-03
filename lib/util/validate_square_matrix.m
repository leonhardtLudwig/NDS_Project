function n = validate_square_matrix(M, name, allowEmpty)
%VALIDATE_SQUARE_MATRIX Check that M is a real, finite, square matrix.
%
%   n = VALIDATE_SQUARE_MATRIX(M, name) throws a descriptive error unless M
%   is a real, finite, square numeric matrix, and returns its size n.
%
%   n = VALIDATE_SQUARE_MATRIX(M, name, allowEmpty) permits a 0-by-0 matrix
%   when allowEmpty is true (default false). Empty blocks arise naturally in
%   the block decompositions of the Taylor and Friedkin-Johnsen models.
%
%   name is used in the error message; pass the caller's argument name.
%
%   See also VALIDATE_NONNEGATIVE_MATRIX, VALIDATE_ROW_STOCHASTIC.

    if nargin < 2 || isempty(name)
        name = 'matrix';
    end
    if nargin < 3 || isempty(allowEmpty)
        allowEmpty = false;
    end

    if ~isnumeric(M) || ~isreal(M)
        error('NDS:validate:notRealNumeric', ...
            '%s must be a real numeric matrix (got %s).', name, class(M));
    end
    if ndims(M) ~= 2 %#ok<ISMAT> keep explicit for clarity
        error('NDS:validate:not2D', '%s must be a 2-D matrix.', name);
    end
    if size(M, 1) ~= size(M, 2)
        error('NDS:validate:notSquare', ...
            '%s must be square (got %d-by-%d).', name, size(M, 1), size(M, 2));
    end
    if ~all(isfinite(M(:)))
        error('NDS:validate:notFinite', ...
            '%s must contain only finite values (found Inf or NaN).', name);
    end

    n = size(M, 1);

    if n == 0 && ~allowEmpty
        error('NDS:validate:emptyMatrix', '%s must not be empty.', name);
    end
end
