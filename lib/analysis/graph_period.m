function h = graph_period(A, nodes)
%GRAPH_PERIOD Period of a strongly connected subgraph.
%
%   h = GRAPH_PERIOD(A) returns the period of the digraph of A, assuming it
%   is strongly connected.
%
%   h = GRAPH_PERIOD(A, nodes) restricts the computation to the subgraph
%   induced on the given node indices, which is the usual case: periodicity
%   only matters for the CLOSED strong components.
%
%   Return value
%       h = 1   aperiodic (the usual, well-behaved case)
%       h > 1   periodic with period h; the French-DeGroot model then fails
%               to converge and opinions oscillate for almost every initial
%               condition
%       h = 0   the subgraph contains no cycle at all (also aperiodic, but
%               reported distinctly so callers can tell the cases apart)
%
%   Method: the period of a strongly connected digraph is the greatest common
%   divisor of its cycle lengths. Assigning BFS levels from an arbitrary root
%   and taking the gcd of level(u) + 1 - level(v) over all edges u -> v gives
%   exactly that gcd, without enumerating cycles. Any self-loop contributes a
%   term of 1 and immediately forces h = 1, which is why positive self-weights
%   always guarantee aperiodicity.
%
%   See also STRONGLY_CONNECTED_COMPONENTS, GRAPH_REPORT.

    n = validate_square_matrix(A, 'A', true);

    if nargin < 2 || isempty(nodes)
        nodes = 1:n;
    end
    validateattributes(nodes, {'numeric'}, ...
        {'vector', 'integer', '>=', 1, '<=', max(n, 1)}, mfilename, 'nodes', 2);
    nodes = unique(nodes(:).');

    if isempty(nodes)
        h = 0;
        return;
    end

    inSubgraph = false(n, 1);
    inSubgraph(nodes) = true;
    mask = (A > 0);

    level = NaN(n, 1);
    root = nodes(1);
    level(root) = 0;

    queue = root;
    h = 0;

    while ~isempty(queue)
        v = queue(1);
        queue(1) = [];
        succ = find(mask(v, :));
        for t = 1:numel(succ)
            w = succ(t);
            if ~inSubgraph(w)
                continue;
            end
            if isnan(level(w))
                level(w) = level(v) + 1;
                queue(end + 1) = w; %#ok<AGROW>
            else
                h = gcd(h, abs(level(v) + 1 - level(w)));
            end
        end
    end

    % A strongly connected subgraph is fully reachable from any of its nodes;
    % if some node was not reached, the caller passed a non-strong set.
    if any(isnan(level(nodes)))
        error('NDS:graphPeriod:notStronglyConnected', ...
            ['The node set supplied to GRAPH_PERIOD is not strongly connected ' ...
             '(node %d is unreachable from node %d). Pass the members of a ' ...
             'single strong component, e.g. from STRONGLY_CONNECTED_COMPONENTS.'], ...
            nodes(find(isnan(level(nodes)), 1)), root);
    end
end
