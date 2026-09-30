function T = limit_report(Xs, labels, tol)
%LIMIT_REPORT Classify the asymptotic behaviour of simulated trajectories.
%
%   T = LIMIT_REPORT(Xs, labels) takes a cell array of n-by-K trajectories,
%   one per run, and returns a table with the columns
%
%       run | converged | limit_spread | consensus | same_limit_as_first
%
%   T = LIMIT_REPORT(Xs, labels, tol) sets the tolerance (default 1e-6).
%
%   FOUR PROPERTIES THAT ARE ROUTINELY CONFLATED
%       converged            the state settles: x(K) and x(K-1) agree. This is
%                            about whether a limit exists at all.
%       consensus            the limit is the SAME for every agent, i.e. its
%                            spread is zero. A converged run is otherwise a
%                            run that converges to DISAGREEMENT.
%       same_limit_as_first  the limit does not depend on the initial
%                            condition. Run the same model from several x(0)
%                            and pass the trajectories together: this column
%                            is the numerical signature of ASYMPTOTIC
%                            STABILITY, which is a property of the system
%                            matrix and is not implied by convergence.
%
%       Asymptotic stability does not imply consensus, and convergence does
%       not imply asymptotic stability. Reading these off a trajectory plot by
%       eye is exactly how they get confused; this table separates them.
%
%   All runs must have the same number of agents. The comparison column is
%   relative to the first run, so pass the runs in a deliberate order.
%
%   Example
%       XA = sim_taylor(A, gamma, u, x0A, t);
%       XB = sim_taylor(A, gamma, u, x0B, t);
%       limit_report({XA, XB}, {'from x0A','from x0B'})
%
%   See also STABILITY_SUMMARY, SIM_TAYLOR, SIM_ABELSON.

    if nargin < 3 || isempty(tol), tol = 1e-6; end
    if ~iscell(Xs)
        error('NDS:limit_report:notCell', ...
            'Xs must be a cell array of trajectories, one per run.');
    end
    s = numel(Xs);

    if nargin < 2 || isempty(labels)
        labels = compose('run %d', (1:s).');
    end
    labels = cellstr(labels);
    if numel(labels) ~= s
        error('NDS:limit_report:sizeMismatch', '%d labels for %d runs.', numel(labels), s);
    end

    n = size(Xs{1}, 1);
    for k = 1:s
        if size(Xs{k}, 1) ~= n
            error('NDS:limit_report:agentMismatch', ...
                'run %d has %d agents, run 1 has %d.', k, size(Xs{k},1), n);
        end
        if size(Xs{k}, 2) < 2
            error('NDS:limit_report:tooShort', 'run %d has fewer than two samples.', k);
        end
    end

    converged = false(s,1);
    spread    = zeros(s,1);
    consensus = false(s,1);
    matches   = false(s,1);

    last1 = Xs{1}(:, end);
    for k = 1:s
        X    = Xs{k};
        last = X(:, end);
        converged(k) = max(abs(last - X(:, end-1))) <= tol;
        spread(k)    = max(last) - min(last);
        consensus(k) = spread(k) <= tol;
        matches(k)   = max(abs(last - last1)) <= tol;
    end

    T = table(string(labels(:)), converged, spread, consensus, matches, ...
        'VariableNames', ...
        {'run','converged','limit_spread','consensus','same_limit_as_first'});
end
