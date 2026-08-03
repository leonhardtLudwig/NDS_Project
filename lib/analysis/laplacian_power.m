function [p, info] = laplacian_power(A, varargin)
%LAPLACIAN_POWER Abelson social power (left null vector of the Laplacian).
%
%   p = LAPLACIAN_POWER(A) returns the non-negative left null vector of the
%   Laplacian L = diag(A*1) - A, normalised to sum to one. A is the RAW
%   non-negative weight matrix of the continuous-time Abelson model; it need
%   not be row-stochastic.
%
%   p = LAPLACIAN_POWER(net) uses net.A.
%
%   [p, info] = LAPLACIAN_POWER(...) also returns
%       info.eigenspaceDim  dimension of the left null space of L
%       info.isConsensus    true when that dimension is 1
%       info.residual       norm(p'*L, Inf)
%       info.minEntry       smallest entry of p before clamping
%
%   Name-value options
%       'Tolerance'  tolerance for the null-space computation
%       'Warn'       warn when the null space is not one-dimensional (default true)
%
%   INTERPRETATION
%       The Abelson model xdot = -L x is ALWAYS convergent (the Laplacian is
%       a singular M-matrix: 0 is semisimple and every other eigenvalue has
%       strictly positive real part, so there is no periodicity obstruction as
%       there is in discrete time). It reaches consensus exactly when the
%       graph is rooted, and then
%
%           x(t) -> (p' x(0)) * 1,     p' L = 0,  p >= 0,  sum(p) = 1.
%
%       As in the discrete case, p' x(t) is a conserved quantity.
%
%   NOTE
%       Because the row sums of A are free in the Abelson model, p generally
%       DIFFERS from SOCIAL_POWER(row_normalize(A)): the row sums set how fast
%       each agent is pulled, and that affects the limit. The two coincide
%       when A is already row-stochastic.
%
%   See also SOCIAL_POWER, PREDICT_LIMIT_ABELSON, GRAPH_REPORT.

    if isstruct(A)
        if ~isfield(A, 'A')
            error('NDS:laplacianPower:badStruct', ...
                'A struct input must be a network built by NET_FROM_MATRIX.');
        end
        A = A.A;
    end

    n = validate_nonnegative_matrix(A, 'A');
    L = diag(sum(A, 2)) - A;

    opts = parse_options(struct( ...
        'Tolerance', [], ...
        'Warn',      true), varargin, mfilename);

    if isempty(opts.Tolerance)
        basis = null(L.');
    else
        basis = null(L.', opts.Tolerance);
    end

    info = struct( ...
        'eigenspaceDim', size(basis, 2), ...
        'isConsensus',   size(basis, 2) == 1, ...
        'residual',      NaN, ...
        'minEntry',      NaN);

    if size(basis, 2) ~= 1
        if opts.Warn
            warning('NDS:laplacianPower:notUnique', ...
                ['The left null space of the Laplacian has dimension %d, so the ' ...
                 'graph is not rooted and consensus is impossible. Use ' ...
                 'PREDICT_LIMIT_ABELSON for the block limit.'], size(basis, 2));
        end
        p = NaN(n, 1);
        return;
    end

    p = basis(:, 1);

    total = sum(p);
    if abs(total) < eps(class(p)) * n
        error('NDS:laplacianPower:degenerate', ...
            'The left null vector sums to zero; check A for numerical corruption.');
    end
    p = p / total;

    info.minEntry = min(p);
    if info.minEntry < -1e-9
        warning('NDS:laplacianPower:negativeEntry', ...
            'Laplacian social power has a significantly negative entry (%.3g).', ...
            info.minEntry);
    end
    p = max(p, 0);
    p = p / sum(p);

    info.residual = norm(p.' * L, Inf);
end
