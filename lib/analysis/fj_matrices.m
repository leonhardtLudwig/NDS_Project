function out = fj_matrices(W, Lambda, varargin)
%FJ_MATRICES Total-influence matrix and influence centrality (Friedkin-Johnsen).
%
%   out = FJ_MATRICES(W, Lambda) computes the algebraic objects that describe
%   the equilibrium of the Friedkin-Johnsen model
%
%       x(k+1) = Lambda*W*x(k) + (I - Lambda)*u.
%
%   Lambda may be given as a diagonal matrix or as a vector of
%   susceptibilities lambda_i in [0,1].
%
%   Output fields
%       lambda       n-by-1 susceptibility vector
%       LW           the substochastic matrix Lambda*W
%       rho          spectral radius of Lambda*W
%       isStable     true when rho < 1 (all agents P-dependent)
%       V            total-influence matrix (I - Lambda*W)^{-1} (I - Lambda),
%                    NaN when the model is not asymptotically stable
%       c            influence centrality, c = V'*ones(n,1)/n
%       rankV        numerical rank of V
%       svdV         singular values of V
%       isRowStochasticV  sanity check that V has unit row sums
%       condition    condition number of (I - Lambda*W)
%
%   Name-value options
%       'Tolerance'  margin below 1 required of rho to declare stability
%                    (default 1e-12)
%       'Warn'       warn when the model is not asymptotically stable
%                    (default true)
%
%   THEORY (Part I, Theorem 21 and Corollary 22)
%       Lambda*W is SUBSTOCHASTIC, so the consensus direction 1 is no longer
%       invariant. When every agent is P-dependent, Lambda*W is Schur stable
%       and the model has a unique globally attracting equilibrium
%       x(inf) = V*u, with V ROW-STOCHASTIC. Final opinions are therefore
%       convex combinations of the prejudices: disagreement is persistent but
%       BOUNDED -- cleavage, not divergence.
%
%   THE RANK IS THE POINT
%       French-DeGroot:    lim W^k = 1*p'   -- RANK ONE      -> consensus
%       Friedkin-Johnsen:  x(inf) = V*u, V generically FULL RANK
%                          -> every agent keeps a permanent trace of its own
%                             prejudice
%       Both limit operators are row-stochastic; the RANK is what separates
%       consensus from cleavage. Inspect rankV and svdV to see it.
%
%   INFLUENCE CENTRALITY
%       c(i) is the mean weight of agent i's prejudice across all agents'
%       final opinions, and satisfies mean(x(inf)) = c'*u. With Lambda = alpha*I
%       it converges to French's social power as alpha -> 1 (Lemma 24), and it
%       reproduces PageRank with alpha = 1 - m and uniform prejudice.
%
%   See also SIM_FRIEDKIN_JOHNSEN, PREDICT_LIMIT_FJ, FJ_LAMBDA, SOCIAL_POWER.

    n = validate_row_stochastic(W, 'W');
    lambda = diagonal_parameter(Lambda, n, 'Lambda', 0, 1);

    opts = parse_options(struct( ...
        'Tolerance', 1e-12, ...
        'Warn',      true), varargin, mfilename);

    LW = lambda .* W;                    % same as diag(lambda) * W
    rho = max(abs(eig(LW)));

    out = struct();
    out.lambda    = lambda;
    out.LW        = LW;
    out.rho       = rho;
    out.isStable  = rho < 1 - opts.Tolerance;
    out.V         = NaN(n, n);
    out.c         = NaN(n, 1);
    out.rankV     = NaN;
    out.svdV      = NaN(n, 1);
    out.isRowStochasticV = false;
    out.condition = NaN;

    if ~out.isStable
        if opts.Warn
            warning('NDS:fjMatrices:notStable', ...
                ['rho(Lambda*W) = %.12g is not below 1, so the model is not ' ...
                 'asymptotically stable: some agents are P-independent (or ' ...
                 'Lambda = I, which reduces the model to French-DeGroot). ' ...
                 'Use PREDICT_LIMIT_FJ, which handles the block decomposition.'], rho);
        end
        return;
    end

    K = eye(n) - LW;
    out.condition = cond(K);
    if out.condition > 1e12 && opts.Warn
        warning('NDS:fjMatrices:illConditioned', ...
            ['(I - Lambda*W) is ill-conditioned (cond = %.3g). This is expected ' ...
             'as lambda approaches 1, where the model degenerates to ' ...
             'French-DeGroot; interpret V with care.'], out.condition);
    end

    out.V = K \ diag(1 - lambda);
    out.c = out.V.' * ones(n, 1) / n;
    out.svdV = svd(out.V);
    out.rankV = rank(out.V);
    out.isRowStochasticV = is_row_stochastic(out.V, 1e-8);
end
