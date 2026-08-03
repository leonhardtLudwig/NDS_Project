function [xinf, info] = predict_limit_degroot(W, x0, varargin)
%PREDICT_LIMIT_DEGROOT Closed-form limit of the French-DeGroot model.
%
%   [xinf, info] = PREDICT_LIMIT_DEGROOT(W, x0) returns the limit of
%   x(k+1) = W x(k) predicted by theory, without simulating.
%
%   W may be a matrix or a network struct. x0 may be a scalar, an n-vector or
%   an n-by-d matrix.
%
%   info fields
%       report   the GRAPH_REPORT structure
%       mode     'consensus' | 'blocks'
%       p        social power vector (consensus case only)
%       Winf     limit matrix lim W^k (blocks case only)
%       iters    squaring iterations used (blocks case only)
%
%   Name-value options
%       'Tolerance'  convergence tolerance for the limit matrix (default 1e-14)
%       'MaxSquare'  maximum repeated-squaring steps (default 100)
%
%   An error is raised when the model does NOT converge -- that is, when some
%   closed strong component is periodic. Callers that must not fail should go
%   through SAFE_PREDICT, which is what the simulators do.
%
%   METHOD
%       * Rooted and aperiodic: lim W^k = 1*p' is RANK ONE, so every agent
%         converges to p'*x(0) with p the social power vector.
%       * Convergent but not rooted: several closed strong components, so the
%         limit is a genuine matrix, not a rank-one one, and the group settles
%         into BLOCKS. lim W^k is obtained by repeated squaring, which reaches
%         W^(2^m) in m products.
%
%   See also SOCIAL_POWER, GRAPH_REPORT, SIM_DEGROOT.

    narginchk(2, Inf);

    W = network_matrix(W, 'W');
    n = validate_row_stochastic(W, 'W');
    X0 = prepare_state(x0, n, 'x0');

    opts = parse_options(struct( ...
        'Tolerance', 1e-14, ...
        'MaxSquare', 100), varargin, mfilename);

    report = graph_report(W);

    info = struct('report', report, 'mode', '', 'p', [], 'Winf', [], 'iters', 0);

    if ~report.isConvergent
        periodic = report.closedComponents(report.periods(report.closedComponents) > 1);
        error('NDS:predictDegroot:notConvergent', ...
            ['The model does not converge: closed strong component(s) %s are ' ...
             'PERIODIC, so opinions oscillate for almost every initial condition. ' ...
             'Add self-weights (see the SelfWeight option of the network builders) ' ...
             'to make the graph aperiodic.'], mat2str(periodic));
    end

    if report.reachesConsensus
        p = social_power(W, 'Warn', false);
        info.mode = 'consensus';
        info.p = p;
        xinf = repmat(p.' * X0, n, 1);
        return;
    end

    % Convergent but with several closed components: the limit has rank > 1.
    Wk = W;
    iters = 0;
    for m = 1:opts.MaxSquare
        Wnext = Wk * Wk;
        iters = m;
        if norm(Wnext - Wk, Inf) <= opts.Tolerance
            Wk = Wnext;
            break;
        end
        Wk = Wnext;
    end

    info.mode = 'blocks';
    info.Winf = Wk;
    info.iters = iters;
    xinf = Wk * X0;
end
