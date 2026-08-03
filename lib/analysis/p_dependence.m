function [isPDependent, info] = p_dependence(W, anchored)
%P_DEPENDENCE Split agents into prejudice-dependent and prejudice-independent.
%
%   isPDependent = P_DEPENDENCE(W, anchored) classifies every agent of the
%   influence graph W with respect to a set of ANCHORED agents -- those tied
%   to an external prejudice (lambda_i < 1 in Friedkin-Johnsen, gamma_i > 0
%   in Taylor).
%
%   Inputs
%       W        : n-by-n non-negative influence matrix (row i = who i listens to)
%       anchored : logical n-vector, or a vector of agent indices
%
%   Outputs
%       isPDependent : n-by-1 logical, true for P-dependent agents
%       info.pDependent   / info.pIndependent : index vectors
%       info.nPDependent  / info.nPIndependent
%       info.allDependent : true when every agent is P-dependent
%
%   DEFINITION (Proskurnikov & Tempo, Part I, Sections 5.2 and 6.1)
%       Agent i is P-DEPENDENT if it is itself anchored, or if some anchored
%       agent influences it through a chain of interpersonal influence.
%       Otherwise it is P-INDEPENDENT and evolves by pure averaging,
%       untouched by any prejudice.
%
%   WHY IT MATTERS
%       Asymptotic stability of the Taylor and Friedkin-Johnsen models holds
%       IF AND ONLY IF every agent is P-dependent (Corollaries 19 and 22).
%       This is the mirror image of the consensus condition: for consensus you
%       need ONE agent that reaches everyone; for stability you need the
%       ANCHOR SET to reach everyone.
%
%   IMPLEMENTATION
%       "Anchored agent j influences agent i" means there is a walk j -> i in
%       the influence graph, equivalently a walk i -> j in the listening graph
%       of W. So the P-dependent set is found by a breadth-first search from
%       the anchored agents along REVERSED edges of W.
%
%   See also FJ_MATRICES, TAYLOR_MATRICES, PREDICT_LIMIT_FJ, PREDICT_LIMIT_TAYLOR.

    narginchk(2, 2);
    n = validate_nonnegative_matrix(W, 'W', true);

    anchoredMask = normalise_anchor_set(anchored, n);

    mask = W > 0;
    isPDependent = anchoredMask;
    queue = find(anchoredMask).';

    while ~isempty(queue)
        v = queue(1);
        queue(1) = [];
        % Agents that listen to v can be influenced by whatever reaches v.
        listeners = find(mask(:, v)).';
        for t = 1:numel(listeners)
            w = listeners(t);
            if ~isPDependent(w)
                isPDependent(w) = true;
                queue(end + 1) = w; %#ok<AGROW>
            end
        end
    end

    info = struct();
    info.pDependent    = find(isPDependent).';
    info.pIndependent  = find(~isPDependent).';
    info.nPDependent   = numel(info.pDependent);
    info.nPIndependent = numel(info.pIndependent);
    info.allDependent  = (info.nPIndependent == 0);
    info.anchored      = find(anchoredMask).';
end

% -------------------------------------------------------------------------
function mask = normalise_anchor_set(anchored, n)
%NORMALISE_ANCHOR_SET Accept either a logical mask or a list of indices.

    if islogical(anchored)
        if numel(anchored) ~= n
            error('NDS:pDependence:badMaskLength', ...
                'A logical anchor mask must have %d entries (got %d).', ...
                n, numel(anchored));
        end
        mask = anchored(:);
        return;
    end

    validateattributes(anchored, {'numeric'}, {'vector', 'integer'}, ...
        mfilename, 'anchored', 2);
    if ~isempty(anchored) && (min(anchored) < 1 || max(anchored) > n)
        error('NDS:pDependence:indexOutOfRange', ...
            'Anchor indices must lie in 1..%d.', n);
    end
    mask = false(n, 1);
    mask(anchored) = true;
end
