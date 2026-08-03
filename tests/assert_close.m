function assert_close(actual, expected, tol, message, varargin)
%ASSERT_CLOSE Fail a test unless two numeric arrays agree to a tolerance.
%
%   ASSERT_CLOSE(actual, expected) fails unless the two arrays have the same
%   size and agree to within 1e-10 in the infinity norm.
%
%   ASSERT_CLOSE(actual, expected, tol) uses the given absolute tolerance.
%
%   ASSERT_CLOSE(actual, expected, tol, message, ...) prepends a SPRINTF
%   formatted message to the failure report.
%
%   The failure report always includes the actual discrepancy, because a test
%   that says only "assertion failed" costs far more time than one that says
%   by how much and where.
%
%   See also RUN_ALL_TESTS.

    narginchk(2, Inf);
    if nargin < 3 || isempty(tol)
        tol = 1e-10;
    end
    if nargin < 4 || isempty(message)
        message = 'values differ';
    end
    label = sprintf(message, varargin{:});

    if ~isequal(size(actual), size(expected))
        error('NDS:test:sizeMismatch', ...
            '%s: size %s ~= expected size %s.', ...
            label, mat2str(size(actual)), mat2str(size(expected)));
    end

    delta = abs(double(actual(:)) - double(expected(:)));
    [worst, idx] = max(delta);

    if ~(worst <= tol)
        error('NDS:test:toleranceExceeded', ...
            '%s: max |difference| = %.6g at linear index %d (tol %.3g).', ...
            label, worst, idx, tol);
    end
end
