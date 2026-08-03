function [xinf, info] = predict_limit_fj(W, Lambda, u, x0, varargin)
%PREDICT_LIMIT_FJ Closed-form limit of the Friedkin-Johnsen model.
%
%   [xinf, info] = PREDICT_LIMIT_FJ(W, Lambda, u, x0) returns the limit of
%
%       x(k+1) = Lambda*W*x(k) + (I - Lambda)*u
%
%   predicted by Theorem 21 of Proskurnikov & Tempo, Part I, without
%   simulating.
%
%   info fields
%       mode          'degroot' | 'stable' | 'blocks'
%       pDependent    indices of the P-dependent agents
%       pIndependent  indices of the P-independent agents
%       V             total-influence matrix (mode 'stable' only)
%       x2inf         limit of the P-independent block (mode 'blocks' only)
%
%   METHOD -- the block decomposition of Theorem 21
%       Agent i is P-DEPENDENT if it is anchored (lambda_i < 1) or is reached
%       by an anchored agent. A P-INDEPENDENT agent has lambda_i = 1 and
%       listens only to other P-independent agents, so W22 is row-stochastic
%       and that block is a pure French-DeGroot model:
%
%           x2(inf) = French-DeGroot limit on the sub-network.
%
%       The P-dependent block then satisfies
%
%           (I - Lambda11 W11) x1(inf) = (I - Lambda11) u1 + Lambda11 W12 x2(inf),
%
%       where Lambda11*W11 is Schur stable, so the solve is well posed and V
%       is row-stochastic.
%
%       When every agent is P-dependent this collapses to
%           x(inf) = V u,   V = (I - Lambda W)^{-1} (I - Lambda),
%       independent of x0. When Lambda = I the model IS French-DeGroot and is
%       delegated to PREDICT_LIMIT_DEGROOT.
%
%   NUMERICS
%       The linear system is solved with the backslash operator, never by
%       forming an explicit inverse. (I - Lambda W) becomes ill-conditioned as
%       lambda approaches 1, which is exactly where the model degenerates to
%       the marginally stable French-DeGroot dynamics; FJ_MATRICES reports the
%       condition number.
%
%   See also SIM_FRIEDKIN_JOHNSEN, FJ_MATRICES, P_DEPENDENCE, PREDICT_LIMIT_DEGROOT.

    narginchk(4, Inf);

    W = network_matrix(W, 'W');
    n = validate_row_stochastic(W, 'W');
    lambda = diagonal_parameter(Lambda, n, 'Lambda', 0, 1);
    [X0, d] = prepare_state(x0, n, 'x0');
    U = match_input_dimension(u, n, d, 'u');

    parse_options(struct(), varargin, mfilename);   % reject stray arguments

    anchored = lambda < 1;

    info = struct( ...
        'mode',         '', ...
        'pDependent',   zeros(1, 0), ...
        'pIndependent', 1:n, ...
        'V',            [], ...
        'x2inf',        []);

    if ~any(anchored)
        % Lambda = I: the model is exactly French-DeGroot.
        info.mode = 'degroot';
        [xinf, degrootInfo] = predict_limit_degroot(W, X0);
        info.degroot = degrootInfo;
        return;
    end

    [~, pinfo] = p_dependence(W, anchored);
    idxD = pinfo.pDependent;
    idxI = pinfo.pIndependent;
    info.pDependent = idxD;
    info.pIndependent = idxI;

    lamD = lambda(idxD);
    K11 = eye(numel(idxD)) - lamD .* W(idxD, idxD);
    rhs = (1 - lamD) .* U(idxD, :);

    if isempty(idxI)
        info.mode = 'stable';
        info.V = K11 \ diag(1 - lamD);
        x1inf = K11 \ rhs;
        xinf = zeros(n, d);
        xinf(idxD, :) = x1inf;
        return;
    end

    % P-independent agents are fully open and listen only to each other, so
    % their sub-network is row-stochastic and evolves by pure averaging.
    x2inf = predict_limit_degroot(W(idxI, idxI), X0(idxI, :));

    rhs = rhs + lamD .* (W(idxD, idxI) * x2inf);
    x1inf = K11 \ rhs;

    xinf = zeros(n, d);
    xinf(idxD, :) = x1inf;
    xinf(idxI, :) = x2inf;

    info.mode = 'blocks';
    info.x2inf = x2inf;
end
