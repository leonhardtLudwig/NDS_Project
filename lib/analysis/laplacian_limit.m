function P = laplacian_limit(A)
%LAPLACIAN_LIMIT Limit of the Abelson flow: the projection onto ker L.
%
%   P = LAPLACIAN_LIMIT(A) returns
%
%       P = lim_{t -> inf} exp(-L[A] t)
%
%   the operator that maps an initial condition to its asymptotic opinion
%   vector, x(inf) = P x(0). It is the continuous-time counterpart of
%   LIMIT_MATRIX.
%
%   READING THE RESULT
%       rank(P) == 1      the model reaches CONSENSUS; then P = 1 p' and every
%                         row equals the social power vector LAPLACIAN_POWER(A)
%       rank(P) == k > 1  it converges to one value per CLOSED strong
%                         component: k limits, no consensus
%
%       rank(P) always equals the number of closed strong components, which is
%       also the multiplicity of the eigenvalue 0 of L.
%
%   HOW IT IS COMPUTED
%       P is the spectral projection onto ker L along range L, so with
%       R = null(L) and Q = null(L') it is
%
%           P = R (Q'R)^{-1} Q'
%
%       This is exact: no time horizon has to be guessed, unlike EXPM(-L*T)
%       for a "large enough" T, where large enough depends on the spectral
%       gap. The result satisfies P^2 = P and P L = 0.
%
%   Unlike the discrete-time case there is nothing to check first: L is a
%   singular M-matrix, its only eigenvalue on the imaginary axis is 0 and that
%   eigenvalue is semisimple, so the limit exists for EVERY non-negative A.
%
%   Example
%       A = ring_graph(6);
%       P = laplacian_limit(A);
%       rank(P)                          % 1 -> consensus
%       norm(P - ones(6,1)*laplacian_power(A)')
%
%   See also LIMIT_MATRIX, LAPLACIAN_POWER, LAPLACIAN_REPORT, SIM_ABELSON.

    check_square(A, 'A');
    if any(A(:) < 0)
        error('NDS:laplacian_limit:negative', 'A must be non-negative.');
    end

    L = laplacian(A);
    R = null(L);                         % right null space: the equilibria
    Q = null(L.');                       % left  null space: the invariants

    P = R * ((Q.' * R) \ Q.');

    if norm(P*P - P, Inf) > 1e-8 * max(1, norm(P, Inf))
        error('NDS:laplacian_limit:notProjection', ...
            ['The computed limit is not idempotent, which means the null ' ...
             'spaces of L were resolved badly. Check that A is a sensible ' ...
             'weight matrix.']);
    end
end
