function h = graph_period(A, nodes)
%GRAPH_PERIOD Period of a strongly connected subgraph.
%
%   h = GRAPH_PERIOD(A) returns the period of the digraph of A, assumed
%   strongly connected.
%
%   h = GRAPH_PERIOD(A, nodes) restricts to the subgraph induced on the given
%   nodes -- the usual case, since periodicity only matters for the CLOSED
%   strong components.
%
%       h = 1   aperiodic (the well-behaved case)
%       h > 1   periodic with period h: the French-DeGroot model then fails to
%               converge and opinions oscillate for almost every x(0)
%       h = 0   the subgraph has no cycle at all (also aperiodic)
%
%   METHOD
%       The period of a strongly connected digraph is the gcd of its cycle
%       lengths. Assigning breadth-first levels from any root and taking the
%       gcd of level(u) + 1 - level(v) over all edges u -> v gives exactly
%       that, without enumerating cycles. A self-loop contributes a term of
%       1, which is why positive self-weights always guarantee aperiodicity.
%
%   Example
%       graph_period(ring_graph(6))         % 6  -> oscillates
%       graph_period(ring_graph(6, 0.2))    % 1  -> converges
%
%   See also STRONG_COMPONENTS, GRAPH_SUMMARY.

    n = check_square(A, 'A');
    if nargin < 2 || isempty(nodes), nodes = 1:n; end

    inside = false(n, 1);
    inside(nodes) = true;
    adjacency = A > 0;

    level = NaN(n, 1);
    level(nodes(1)) = 0;
    queue = nodes(1);
    h = 0;

    while ~isempty(queue)
        v = queue(1);
        queue(1) = [];
        for w = find(adjacency(v, :))
            if ~inside(w), continue; end
            if isnan(level(w))
                level(w) = level(v) + 1;
                queue(end+1) = w; %#ok<AGROW>
            else
                h = gcd(h, abs(level(v) + 1 - level(w)));
            end
        end
    end

    if any(isnan(level(nodes)))
        error('NDS:graph_period:notStrong', ...
            'The given node set is not strongly connected.');
    end
end
