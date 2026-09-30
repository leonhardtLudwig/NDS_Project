function s = laplacian_report(A, name)
%LAPLACIAN_REPORT Structural facts of a network, read for continuous time.
%
%   LAPLACIAN_REPORT(A) prints, in a fixed layout, the quantities that decide
%   the behaviour of the Abelson model xdot = -L[A] x: the interaction
%   strengths, the strong-component structure, whether the graph is rooted,
%   the multiplicity of the eigenvalue 0 of L, the spectral gap, and which
%   agents are stubborn.
%
%   LAPLACIAN_REPORT(A, name) labels the report with a name.
%
%   s = LAPLACIAN_REPORT(...) also returns the GRAPH_SUMMARY structure, plus
%   the continuous-time fields
%
%       s.ctConsensus   consensus in continuous time (Theorem 2.1: rooted)
%       s.zeroMult      multiplicity of the eigenvalue 0 of L
%       s.gap           min Re(lambda) over the nonzero eigenvalues of L
%       s.stubborn      agents with an all-zero row of A
%
%   WHY NOT MATRIX_REPORT
%       MATRIX_REPORT prints the DISCRETE-TIME verdict, in which convergence
%       needs every closed component to be aperiodic. In continuous time that
%       condition is absent: e^{-Lt} converges for ANY non-negative A
%       (Corollary 2.1), and consensus holds exactly when the graph is rooted
%       (Theorem 2.1). Reporting the discrete-time fields here would state the
%       wrong conclusion -- the directed cycle and the bidirectional star both
%       oscillate forever under French-DeGroot and both reach consensus here.
%
%   WHAT THE LINES MEAN
%       strengths      row sums of A are free; they set how fast each agent is
%                      pulled, not a budget that must add to one
%       closed         mult(0 of L) equals the number of closed components,
%                      exactly as mult(1 of W) does in discrete time
%       gap            min Re lambda over lambda ~= 0 sets the convergence
%                      rate; for an undirected graph it is the Fiedler value
%       stubborn       a_ij = 0 for all j means xdot_i = 0 (section 2.3)
%
%   Example
%       s = laplacian_report(ring_graph(6), 'A');
%
%   See also LAPLACIAN, LAPLACIAN_POWER, GRAPH_SUMMARY, MATRIX_REPORT.

    if nargin < 2 || isempty(name)
        name = inputname(1);
        if isempty(name), name = 'A'; end
    end

    n = check_square(A, 'A');
    if any(A(:) < 0)
        error('NDS:laplacian_report:negative', 'A must be non-negative.');
    end

    L = laplacian(A);
    s = graph_summary(A);

    ev   = eig(L);
    zero = abs(ev) < 1e-9 * max(1, norm(L, Inf));
    s.ctConsensus = s.rooted;
    s.zeroMult    = nnz(zero);
    if all(zero)
        s.gap = 0;
    else
        s.gap = min(real(ev(~zero)));
    end
    s.stubborn = find(sum(A, 2) == 0).';

    dout = sum(A, 2).';
    din  = sum(A, 1);

    fprintf('%s   (%d agents, continuous time)\n', name, n);
    fprintf('  strengths (row sums of A): %s\n', mat2str(round(dout, 4)));
    fprintf('  in-strengths (col sums)  : %s   weight-balanced: %s\n', ...
        mat2str(round(din, 4)), yesno(max(abs(dout - din)) < 1e-12));
    fprintf('  strong components : %d   closed: %d\n', ...
        numel(s.components), numel(s.closed));
    fprintf('  rooted: %-4s  ->  %s\n', yesno(s.rooted), verdict(s.rooted));
    fprintf('  eigenvalue 0 of L: multiplicity %d   spectral gap: %.4f\n', ...
        s.zeroMult, s.gap);

    if ~isempty(s.stubborn)
        fprintf('  stubborn agents (zero rows of A): %s\n', mat2str(s.stubborn));
    end

    if nargout == 0
        clear s;
    end
end

% -------------------------------------------------------------------------
function t = yesno(tf)
    if tf, t = 'yes'; else, t = 'no'; end
end

% -------------------------------------------------------------------------
function t = verdict(rooted)
%VERDICT The continuous-time model always converges; only the limit varies.
    if rooted
        t = 'converges to CONSENSUS at p''x(0)';
    else
        t = 'converges, but NOT to consensus (one limit per closed component)';
    end
end
