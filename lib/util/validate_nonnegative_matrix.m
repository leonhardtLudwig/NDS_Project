function n = validate_nonnegative_matrix(A, name, allowEmpty)
%VALIDATE_NONNEGATIVE_MATRIX Check that A is a square, non-negative matrix.
%
%   n = VALIDATE_NONNEGATIVE_MATRIX(A, name) throws a descriptive error
%   unless A is a real, finite, square matrix with no negative entries, and
%   returns its size n.
%
%   n = VALIDATE_NONNEGATIVE_MATRIX(A, name, allowEmpty) permits a 0-by-0
%   matrix when allowEmpty is true (default false).
%
%   Every model in this project (French-DeGroot, Abelson, Taylor,
%   Friedkin-Johnsen) requires non-negative influence weights. Signed
%   networks belong to a different model family (see docs).
%
%   See also VALIDATE_SQUARE_MATRIX, VALIDATE_ROW_STOCHASTIC.

    if nargin < 2 || isempty(name)
        name = 'matrix';
    end
    if nargin < 3 || isempty(allowEmpty)
        allowEmpty = false;
    end

    n = validate_square_matrix(A, name, allowEmpty);

    if any(A(:) < 0)
        [r, c] = find(A < 0, 1);
        error('NDS:validate:negativeEntry', ...
            ['%s must be non-negative; found %g at entry (%d,%d). ' ...
             'Signed influence networks are outside the scope of these models.'], ...
            name, A(r, c), r, c);
    end
end
