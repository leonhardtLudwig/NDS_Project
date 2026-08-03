function [xinf, info] = predict_limit_taylor(A, Gamma, u, x0, varargin)
%PREDICT_LIMIT_TAYLOR Closed-form limit of the Taylor model.
%
%   [xinf, info] = PREDICT_LIMIT_TAYLOR(A, Gamma, u, x0) returns the limit of
%
%       xdot = -(L[A] + Gamma) x + Gamma u
%
%   predicted by Theorem 18 of Proskurnikov & Tempo, Part I, without
%   integrating.
%
%   info fields
%       mode          'stable' when every agent is P-dependent, else 'blocks'
%       pDependent    indices of the P-dependent agents
%       pIndependent  indices of the P-independent agents
%       taylor        the TAYLOR_MATRICES structure
%       x2inf         limit of the P-independent block ('blocks' mode only)
%
%   METHOD -- the block decomposition of Theorem 18
%       Agent i is P-DEPENDENT if it is anchored (gamma_i > 0) or is reached
%       by an anchored agent. A P-INDEPENDENT agent listens only to other
%       P-independent agents, so that block is a pure Abelson model:
%
%           x2(inf) = Abelson limit of the sub-network on those agents.
%
%       The P-dependent block is then driven by the prejudices and by the
%       settled P-independent opinions, and its equilibrium solves
%
%           (L11 + Gamma11) x1(inf) = Gamma11 u1 - L12 x2(inf),
%
%       where -L12 = A(pDependent, pIndependent) >= 0. L11 + Gamma11 is a
%       NONSINGULAR M-matrix, so the solve is well posed and the resulting
%       map is stochastic: final opinions are convex combinations of the
%       prejudices and the P-independent limits.
%
%       When every agent is P-dependent this collapses to the familiar
%           x(inf) = (L + Gamma) \ (Gamma u),
%       which is independent of x0 -- the group forgets where it started and
%       remembers only what anchors it.
%
%   See also SIM_TAYLOR, TAYLOR_MATRICES, P_DEPENDENCE, PREDICT_LIMIT_ABELSON.

    narginchk(4, Inf);

    A = network_matrix(A, 'A');
    n = validate_nonnegative_matrix(A, 'A');
    gamma = diagonal_parameter(Gamma, n, 'Gamma', 0, Inf);
    [X0, d] = prepare_state(x0, n, 'x0');
    U = match_input_dimension(u, n, d, 'u');

    parse_options(struct(), varargin, mfilename);   % reject stray arguments

    L = diag(sum(A, 2)) - A;

    anchored = gamma > 0;
    [~, pinfo] = p_dependence(A, anchored);
    idxD = pinfo.pDependent;
    idxI = pinfo.pIndependent;

    info = struct( ...
        'mode',         '', ...
        'pDependent',   idxD, ...
        'pIndependent', idxI, ...
        'taylor',       taylor_matrices(A, gamma), ...
        'x2inf',        []);

    if isempty(idxD)
        % Nobody is anchored: the model degenerates to pure Abelson.
        info.mode = 'blocks';
        [xinf, abelsonInfo] = predict_limit_abelson(A, X0);
        info.x2inf = xinf;
        info.abelson = abelsonInfo;
        return;
    end

    M11 = L(idxD, idxD) + diag(gamma(idxD));
    rhs = gamma(idxD) .* U(idxD, :);

    if isempty(idxI)
        info.mode = 'stable';
        xinf = M11 \ rhs;                 % idxD is a permutation of 1..n here
        if ~isequal(idxD, 1:n)
            full = zeros(n, d);
            full(idxD, :) = xinf;
            xinf = full;
        end
        return;
    end

    % P-independent agents listen only to each other, so their sub-network is
    % self-contained and evolves as a pure Abelson model.
    x2inf = predict_limit_abelson(A(idxI, idxI), X0(idxI, :));

    % -L12 = A(idxD, idxI) >= 0.
    rhs = rhs + A(idxD, idxI) * x2inf;
    x1inf = M11 \ rhs;

    xinf = zeros(n, d);
    xinf(idxD, :) = x1inf;
    xinf(idxI, :) = x2inf;

    info.mode = 'blocks';
    info.x2inf = x2inf;
end
