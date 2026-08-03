function [comp, nComp, members] = strongly_connected_components(A)
%STRONGLY_CONNECTED_COMPONENTS Partition a digraph into strong components.
%
%   [comp, nComp, members] = STRONGLY_CONNECTED_COMPONENTS(A) computes the
%   strongly connected components of the digraph whose edges are the strictly
%   positive entries of A.
%
%   Outputs
%       comp    : n-by-1 vector of component labels in 1..nComp
%       nComp   : number of components
%       members : nComp-by-1 cell array of node indices per component
%
%   Edge convention: A(i,j) > 0 is an edge i -> j. With the project's
%   influence convention that means "agent i listens to agent j", so this
%   operates on the LISTENING graph.
%
%   Kosaraju's algorithm is used, implemented with explicit stacks so that
%   deep graphs cannot overflow the MATLAB recursion limit. The
%   implementation is deliberately self-contained rather than delegating to
%   CONNCOMP/DIGRAPH: it is the foundation of every structural result in the
%   project and is therefore unit-tested directly.
%
%   Components are labelled in reverse topological order of the condensation,
%   but no ordering is guaranteed; use GRAPH_REPORT for the derived
%   properties (closed components, rootedness, periodicity).
%
%   See also GRAPH_REPORT, GRAPH_PERIOD.

    n = validate_square_matrix(A, 'A', true);

    comp = zeros(n, 1);
    nComp = 0;
    members = cell(0, 1);

    if n == 0
        return;
    end

    mask = A > 0;

    successors = cell(n, 1);
    predecessors = cell(n, 1);
    for ii = 1:n
        successors{ii}   = find(mask(ii, :));
        predecessors{ii} = find(mask(:, ii)).';
    end

    % --- pass 1: iterative DFS on G, recording finishing order -----------
    visited = false(n, 1);
    ptr = zeros(n, 1);
    order = zeros(n, 1);
    nOrder = 0;

    for start = 1:n
        if visited(start)
            continue;
        end
        visited(start) = true;
        ptr(start) = 0;
        stack = start;

        while ~isempty(stack)
            v = stack(end);
            ptr(v) = ptr(v) + 1;
            nb = successors{v};
            if ptr(v) <= numel(nb)
                w = nb(ptr(v));
                if ~visited(w)
                    visited(w) = true;
                    ptr(w) = 0;
                    stack(end + 1) = w; %#ok<AGROW>
                end
            else
                nOrder = nOrder + 1;
                order(nOrder) = v;
                stack(end) = [];
            end
        end
    end

    % --- pass 2: DFS on the reverse graph in reverse finishing order -----
    for k = n:-1:1
        seed = order(k);
        if comp(seed) ~= 0
            continue;
        end
        nComp = nComp + 1;
        comp(seed) = nComp;
        stack = seed;

        while ~isempty(stack)
            v = stack(end);
            stack(end) = [];
            p = predecessors{v};
            for t = 1:numel(p)
                w = p(t);
                if comp(w) == 0
                    comp(w) = nComp;
                    stack(end + 1) = w; %#ok<AGROW>
                end
            end
        end
    end

    members = cell(nComp, 1);
    for c = 1:nComp
        members{c} = find(comp == c).';
    end
end
