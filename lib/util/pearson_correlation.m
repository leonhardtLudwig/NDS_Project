function r = pearson_correlation(x, y)
%PEARSON_CORRELATION Pearson correlation coefficient of two vectors.
%
%   r = PEARSON_CORRELATION(x, y) returns the Pearson product-moment
%   correlation between two equal-length real vectors.
%
%   This wraps the built-in CORRCOEF rather than CORR: CORR belongs to the
%   Statistics and Machine Learning Toolbox, and the project deliberately
%   depends on base MATLAB only, so that the library runs on any
%   installation.
%
%   A constant input has zero variance and no defined correlation; NaN is
%   returned in that case rather than raising an error, since it arises
%   naturally when a measure is identically zero across all agents.
%
%   See also CORRCOEF.

    narginchk(2, 2);
    validateattributes(x, {'numeric'}, {'vector', 'real', 'finite'}, mfilename, 'x', 1);
    validateattributes(y, {'numeric'}, {'vector', 'real', 'finite'}, mfilename, 'y', 2);

    x = double(x(:));
    y = double(y(:));

    if numel(x) ~= numel(y)
        error('NDS:pearsonCorrelation:sizeMismatch', ...
            'x and y must have the same number of elements (%d vs %d).', ...
            numel(x), numel(y));
    end
    if numel(x) < 2
        error('NDS:pearsonCorrelation:tooShort', ...
            'At least two observations are required.');
    end

    if std(x) == 0 || std(y) == 0
        r = NaN;
        return;
    end

    R = corrcoef(x, y);
    r = R(1, 2);
end
