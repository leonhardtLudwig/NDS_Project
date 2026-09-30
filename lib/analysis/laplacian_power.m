function p = laplacian_power(A)
%LAPLACIAN_POWER Social power in continuous time: the left null vector of L.
%
%   p = LAPLACIAN_POWER(A) returns the unique vector with
%
%       p' L[A] = 0 ,      p' 1 = 1 ,      p >= 0
%
%   which is the continuous-time counterpart of SOCIAL_POWER. When the graph
%   is rooted the Abelson model reaches consensus and its limit is
%
%       x(t) -> (p' x(0)) 1                            (Theorem 2.1)
%
%   so p_i is the weight agent i's initial opinion carries in the outcome.
%
%   WHY NOT SOCIAL_POWER
%       SOCIAL_POWER solves p'W = p' and requires a ROW-STOCHASTIC W. The
%       Abelson model does not normalise: A keeps its own row sums, which set
%       how fast each agent is pulled. The corresponding invariant is p'L = 0,
%       and p'x(t) is conserved along the flow.
%
%   RESPONSIVENESS COSTS INFLUENCE
%       Scaling row i of A by c_i makes agent i respond c_i times faster, and
%       changes p to be proportional to C^{-1} p, C = diag(c). An agent that
%       reacts faster to its neighbours therefore ends up with LESS weight in
%       the consensus value, not more. Nothing of the kind can happen in the
%       discrete-time model, where every row is forced to sum to one.
%
%   The vector is unique exactly when the graph has one closed strong
%   component, i.e. when it is rooted. Otherwise the null space of L' has one
%   dimension per closed component and no consensus exists; this function then
%   errors, as SOCIAL_POWER does.
%
%   Example
%       A = ring_graph(6);
%       p = laplacian_power(A)              % uniform: the ring is balanced
%       norm(p' * laplacian(A))             % zero
%
%   See also SOCIAL_POWER, LAPLACIAN, LAPLACIAN_REPORT, SIM_ABELSON.

    n = check_square(A, 'A');
    if any(A(:) < 0)
        error('NDS:laplacian_power:negative', 'A must be non-negative.');
    end

    basis = null(laplacian(A).');        % solve p' L = 0

    if size(basis, 2) ~= 1
        error('NDS:laplacian_power:notUnique', ...
            ['The eigenvalue 0 of L has a %d-dimensional left null space, so the ' ...
             'graph has several closed strong components and consensus is ' ...
             'impossible. Check LAPLACIAN_REPORT(A).'], size(basis, 2));
    end

    p = basis / sum(basis);              % normalise so that p'*1 = 1
    p = max(p, 0);                       % clean up round-off at exact zeros
    p = p / sum(p);
    if n == 0, p = []; end
end
