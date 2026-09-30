function reached = prejudice_reach(A, anchored)
%PREJUDICE_REACH Which agents are reached by a prejudice.
%
%   reached = PREJUDICE_REACH(A, anchored) returns a logical n-vector that is
%   true for every agent that is itself anchored, or that some anchored agent
%   influences through a chain of interpersonal influence.
%
%   anchored is a logical n-vector or a list of agent indices. Typical uses:
%
%       prejudice_reach(W, lambda < 1)     % Friedkin-Johnsen
%       prejudice_reach(A, gamma > 0)      % Taylor
%
%   WHY IT MATTERS
%       The Taylor and Friedkin-Johnsen models are asymptotically stable IF
%       AND ONLY IF every agent is reached. This is the mirror image of the
%       consensus condition: for consensus you need ONE agent that reaches
%       everybody; for stability you need the ANCHOR SET to reach everybody.
%
%   An agent that is NOT reached evolves by pure averaging, untouched by any
%   prejudice, and the equilibrium then depends on x(0).
%
%   Example
%       all(prejudice_reach(path_graph(5), 1))   % the head anchors the chain
%       all(prejudice_reach(path_graph(5), 5))   % the tail anchors nobody
%
%   See also TOTAL_INFLUENCE, TAYLOR_EQUILIBRIUM, GRAPH_SUMMARY.

    n = check_square(A, 'A');

    if islogical(anchored)
        reached = anchored(:);
    else
        reached = false(n, 1);
        reached(anchored) = true;
    end

    % "Anchored j influences i" means a walk j -> i in the influence graph,
    % i.e. a walk i -> j in the listening graph of A. So search backwards.
    adjacency = A > 0;
    queue = find(reached).';

    while ~isempty(queue)
        v = queue(1);
        queue(1) = [];
        for w = find(adjacency(:, v)).'      % agents who listen to v
            if ~reached(w)
                reached(w) = true;
                queue(end+1) = w; %#ok<AGROW>
            end
        end
    end
end
