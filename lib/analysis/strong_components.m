function [comp, members] = strong_components(A)
%STRONG_COMPONENTS Strongly connected components of a digraph.
%
%   [comp, members] = STRONG_COMPONENTS(A) partitions the digraph whose edges
%   are the positive entries of A.
%
%       comp     n-by-1 component label of each node
%       members  cell array listing the nodes of each component
%
%   Edge convention: A(i,j) > 0 is an edge i -> j, i.e. "agent i listens to
%   agent j", so this operates on the LISTENING graph.
%
%   Kosaraju's algorithm, with explicit stacks so that deep graphs cannot
%   overflow the recursion limit.
%
%   Example
%       [comp, members] = strong_components(path_graph(4))
%
%   See also GRAPH_SUMMARY, GRAPH_PERIOD.

    n = check_square(A, 'A');
    adjacency = A > 0;

    % --- pass 1: DFS on G, recording the order in which nodes finish ------
    visited = false(n, 1);
    order = zeros(n, 1);
    filled = 0;
    for start = 1:n
        if visited(start), continue; end
        visited(start) = true;
        stack = start;
        pointer = zeros(n, 1);
        while ~isempty(stack)
            v = stack(end);
            pointer(v) = pointer(v) + 1;
            next = find(adjacency(v, :));
            if pointer(v) <= numel(next)
                w = next(pointer(v));
                if ~visited(w)
                    visited(w) = true;
                    pointer(w) = 0;
                    stack(end+1) = w; %#ok<AGROW>
                end
            else
                filled = filled + 1;
                order(filled) = v;
                stack(end) = [];
            end
        end
    end

    % --- pass 2: DFS on the reverse graph, in reverse finishing order -----
    comp = zeros(n, 1);
    label = 0;
    for k = n:-1:1
        seed = order(k);
        if comp(seed) ~= 0, continue; end
        label = label + 1;
        comp(seed) = label;
        stack = seed;
        while ~isempty(stack)
            v = stack(end);
            stack(end) = [];
            for w = find(adjacency(:, v)).'
                if comp(w) == 0
                    comp(w) = label;
                    stack(end+1) = w; %#ok<AGROW>
                end
            end
        end
    end

    members = arrayfun(@(c) find(comp == c).', 1:label, 'UniformOutput', false).';
end
