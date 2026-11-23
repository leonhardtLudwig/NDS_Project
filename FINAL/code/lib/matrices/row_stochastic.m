function W = row_stochastic(A)
%ROW_STOCHASTIC Normalise the rows of a non-negative matrix to sum to one.
%
%   W = ROW_STOCHASTIC(A) returns
%
%       W = D^{-1} A,     D = diag(A * 1)
%
%   so that every row of W sums to 1. This is the influence matrix used by
%   the French-DeGroot and Friedkin-Johnsen models: w_ij is the weight agent
%   i accords to agent j, and each agent distributes a total weight of 1.
%
%   A row of A that is entirely zero (an agent who accords weight to nobody)
%   would give 0/0. Such a row is given a self-loop, W(i,i) = 1, which makes
%   that agent STUBBORN. That is a modelling decision, not a neutral repair,
%   so it is reported as a warning.
%
%   Example
%       A = [0 1 0; 1 0 1; 0 1 0];
%       W = row_stochastic(A)
%
%   See also LAPLACIAN, IS_ROW_STOCHASTIC.

    if ~isnumeric(A) || ~ismatrix(A) || size(A,1) ~= size(A,2) || any(A(:) < 0)
        error('NDS:row_stochastic:badInput', ...
            'A must be a square non-negative matrix.');
    end

    d = sum(A, 2);
    empty = (d == 0);

    if any(empty)
        warning('NDS:row_stochastic:zeroRow', ...
            'Row(s) %s of A are zero; giving them a self-loop makes those agents stubborn.', ...
            mat2str(find(empty).'));
        A(empty, :) = 0;
        A(sub2ind(size(A), find(empty), find(empty))) = 1;
        d(empty) = 1;
    end

    W = A ./ d;
end
