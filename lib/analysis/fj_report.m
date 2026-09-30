function s = fj_report(W, lambda)
%FJ_REPORT The hypotheses Theorem 4.1 and Corollaries 4.1-4.2 actually need.
%
%   s = FJ_REPORT(W, lambda) inspects the Friedkin-Johnsen model
%
%       x(k+1) = Lambda W x(k) + (I - Lambda) u                        (M4.1)
%
%   and returns the facts that decide its behaviour, BEFORE any simulation:
%
%       s.prejudiced   indices with lambda_i < 1
%       s.frozen       indices with lambda_i = 0, for which x_i(k) = u_i
%                      for every k >= 1
%       s.pdependent   logical n-vector: agents some prejudice reaches
%       s.r            how many of them there are
%       s.rho          rho(Lambda W)
%       s.rho11        rho(Lambda11 W11), the P-dependent block
%       s.regular22    W22 regular (true by convention when r = n)
%       s.stable       asymptotically stable      (Corollary 4.1)
%       s.convergent   a limit exists             (Corollary 4.2)
%
%   FJ_REPORT(W, lambda) with no output prints a readable report.
%
%   WHY IT EXISTS
%       x(inf) = V u with V = (I - Lambda W)^{-1} (I - Lambda) is valid only
%       when the model is asymptotically stable, i.e. only when EVERY agent is
%       P-dependent. Call this first and the hypothesis is checked rather than
%       assumed; s.rho11 < 1 always holds, which is the content of Theorem 4.1.
%
%   TERMINOLOGY
%       lambda_i < 1 makes agent i PREJUDICED. lambda_i = 0 additionally
%       freezes it at u_i from the first step; it is STUBBORN in the sense of
%       the tutorial's Definition (Part I, 3.6) only when u_i = x_i(0) as
%       well, which this function cannot see -- it is given no u and no x(0).
%
%   CONVENTION
%       W(i,j) > 0 means i listens to j, so a prejudice travels ALONG the
%       arrows of G[W]: agent i is P-dependent when a walk i -> ... -> j
%       reaches some prejudiced j. Part I draws the arrows the other way and
%       states the same condition as "a walk from j to i".
%
%   Example
%       W = row_stochastic(ring_graph(6));
%       fj_report(W, [0.5; ones(5,1)])      % one prejudiced agent, all reached
%
%   See also PREJUDICE_REACH, TOTAL_INFLUENCE, FJ_EQUILIBRIUM, GRAPH_SUMMARY.

    n      = check_square(W, 'W');
    lambda = check_vector(lambda, n, 'lambda');

    if ~is_row_stochastic(W)
        error('NDS:fj_report:notStochastic', ...
            'W must be row-stochastic. Use W = row_stochastic(A).');
    end
    if any(lambda < 0) || any(lambda > 1)
        error('NDS:fj_report:badLambda', 'lambda must lie in [0,1].');
    end

    s.prejudiced = find(lambda < 1).';
    s.frozen     = find(lambda == 0).';
    s.pdependent = prejudice_reach(W, lambda < 1);
    s.r          = nnz(s.pdependent);

    s.rho = max(abs(eig(diag(lambda) * W)));

    pd      = s.pdependent;
    s.rho11 = max(abs(eig(diag(lambda(pd)) * W(pd, pd))));

    if s.r == n
        s.regular22 = true;                       % no P-independent block
    else
        s.regular22 = graph_summary(W(~pd, ~pd)).convergent;
    end

    s.stable     = (s.r == n) && ~isempty(s.prejudiced);   % Corollary 4.1
    s.convergent = s.stable || s.regular22;                % Corollary 4.2

    if nargout == 0
        fprintf('prejudiced (lambda < 1) : %s\n', fmt(s.prejudiced));
        fprintf('frozen     (lambda = 0) : %s\n', fmt(s.frozen));
        fprintf('P-dependent             : %s   (%d of %d)\n', ...
            fmt(find(s.pdependent).'), s.r, n);
        fprintf('P-independent           : %s\n', fmt(find(~s.pdependent).'));
        fprintf('rho(Lambda W)           : %.6f\n', s.rho);
        fprintf('rho(Lambda11 W11)       : %.6f   < 1 always, by Theorem 4.1\n', s.rho11);
        if s.r < n
            fprintf('W22 regular             : %d\n', s.regular22);
        end
        fprintf('asymptotically stable   : %d   (Corollary 4.1: all agents P-dependent)\n', s.stable);
        fprintf('convergent              : %d   (Corollary 4.2)\n', s.convergent);
        if ~s.stable
            fprintf('  -> x(inf) = V u does NOT apply; the limit depends on x(0).\n');
        end
        clear s;
    end
end

% -------------------------------------------------------------------------
function t = fmt(v)
    if isempty(v), t = '(none)'; else, t = mat2str(v); end
end
