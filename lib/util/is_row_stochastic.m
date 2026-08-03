function [tf, maxDeviation] = is_row_stochastic(W, tol)
%IS_ROW_STOCHASTIC Test whether W is a row-stochastic matrix.
%
%   tf = IS_ROW_STOCHASTIC(W) returns true when W is non-negative and every
%   row sums to 1 within a default tolerance of 1e-10.
%
%   tf = IS_ROW_STOCHASTIC(W, tol) uses the given absolute tolerance.
%
%   [tf, maxDeviation] = IS_ROW_STOCHASTIC(...) also returns the largest
%   absolute deviation of a row sum from 1, which is handy for diagnostics
%   and for reporting accumulated round-off.
%
%   Project convention: W(i,j) > 0 means agent i accords weight to agent j,
%   so the rows are the objects that must sum to one.
%
%   See also VALIDATE_ROW_STOCHASTIC, ROW_NORMALIZE.

    if nargin < 2 || isempty(tol)
        tol = 1e-10;
    end

    if ~isnumeric(W) || ~isreal(W) || ndims(W) ~= 2 %#ok<ISMAT>
        tf = false;
        maxDeviation = Inf;
        return;
    end

    if isempty(W)
        tf = true;
        maxDeviation = 0;
        return;
    end

    maxDeviation = max(abs(sum(W, 2) - 1));
    tf = all(W(:) >= 0) && maxDeviation <= tol;
end
