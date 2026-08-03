function [xinf, info] = predict_limit_abelson(A, x0, varargin)
%PREDICT_LIMIT_ABELSON Closed-form limit of the Abelson model.
%
%   [xinf, info] = PREDICT_LIMIT_ABELSON(A, x0) returns the limit of
%   xdot = -L[A] x predicted by theory, without integrating.
%
%   A may be a raw non-negative matrix or a network struct (net.A is used).
%
%   info fields
%       report   the GRAPH_REPORT structure for the graph of A
%       mode     'consensus' | 'blocks'
%       p        Laplacian social power (consensus case only)
%       Pinf     limit projector (blocks case only)
%       horizon  the time used to evaluate the projector (blocks case only)
%
%   Name-value options
%       'Horizon'  override the automatic time horizon used in the blocks case
%
%   Unlike the discrete-time model, this one ALWAYS converges, so no error
%   case exists. L is a singular M-matrix: 0 is semisimple and every other
%   eigenvalue has strictly positive real part, so exp(-Lt) converges to the
%   spectral projector onto ker L.
%
%   METHOD
%       * Rooted graph: ker L = span{1}, so x(t) -> (p'x(0))*1 with p the
%         left null vector of L.
%       * Otherwise: the projector is evaluated as exp(-L*T) for a horizon T
%         chosen from the spectral gap -- the smallest positive real part of a
%         non-zero eigenvalue -- so that every decaying mode is suppressed to
%         roughly exp(-40).
%
%   See also LAPLACIAN_POWER, SIM_ABELSON, PREDICT_LIMIT_DEGROOT.

    narginchk(2, Inf);

    A = network_matrix(A, 'A');
    n = validate_nonnegative_matrix(A, 'A');
    X0 = prepare_state(x0, n, 'x0');

    opts = parse_options(struct('Horizon', []), varargin, mfilename);

    L = diag(sum(A, 2)) - A;
    report = graph_report(A);

    info = struct('report', report, 'mode', '', 'p', [], 'Pinf', [], 'horizon', NaN);

    if report.isRooted
        p = laplacian_power(A, 'Warn', false);
        info.mode = 'consensus';
        info.p = p;
        xinf = repmat(p.' * X0, n, 1);
        return;
    end

    % Not rooted: the limit is a projector of rank > 1 (block consensus).
    if isempty(opts.Horizon)
        ev = eig(L);
        positiveReal = real(ev(real(ev) > 1e-10 * max(1, norm(L, Inf))));
        if isempty(positiveReal)
            T = 0;                       % L == 0: nothing ever moves
        else
            T = 40 / min(positiveReal);
        end
    else
        validateattributes(opts.Horizon, {'numeric'}, ...
            {'scalar', 'real', 'nonnegative', 'finite'}, mfilename, 'Horizon');
        T = opts.Horizon;
    end

    Pinf = expm(-L * T);

    info.mode = 'blocks';
    info.Pinf = Pinf;
    info.horizon = T;
    xinf = Pinf * X0;
end
