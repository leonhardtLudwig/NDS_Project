function L = laplacian(A)
%LAPLACIAN Laplacian matrix of a weighted digraph.
%
%   L = LAPLACIAN(A) returns
%
%       L = diag(A * 1) - A
%
%   the matrix appearing in the continuous-time models:
%
%       Abelson   xdot = -L x
%       Taylor    xdot = -(L + Gamma) x + Gamma u
%
%   Row i of L encodes  sum_j a_ij (x_j - x_i), so L*1 = 0 always: a group in
%   which everybody already agrees does not move.
%
%   L is a SINGULAR M-matrix. Its zero eigenvalue is semisimple and every
%   other eigenvalue has strictly positive real part, which is why the
%   Abelson flow always converges.
%
%   Example
%       A = [0 1 0; 1 0 1; 0 1 0];
%       L = laplacian(A)
%       L * ones(3,1)          % zero
%
%   See also ROW_STOCHASTIC, SIM_ABELSON, SIM_TAYLOR.

    if ~isnumeric(A) || ~ismatrix(A) || size(A,1) ~= size(A,2) || any(A(:) < 0)
        error('NDS:laplacian:badInput', ...
            'A must be a square non-negative matrix.');
    end

    L = diag(sum(A, 2)) - A;
end
