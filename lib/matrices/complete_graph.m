function A = complete_graph(n, includeSelf)
%COMPLETE_GRAPH Adjacency matrix of an all-to-all network.
%
%   A = COMPLETE_GRAPH(n) returns ones(n), so that after row normalisation
%   every agent gives weight 1/n to everybody including itself. The
%   French-DeGroot model then reaches consensus in a SINGLE step and social
%   power is uniform.
%
%   A = COMPLETE_GRAPH(n, false) excludes self-weights.
%
%   Use it as a control case: it removes topology as a variable, so any
%   disagreement observed must come from the model, not the network.
%
%   See also RING_GRAPH, STAR_GRAPH, TWO_COMMUNITIES.

    if nargin < 2, includeSelf = true; end

    if includeSelf
        A = ones(n);
    else
        A = ones(n) - eye(n);
    end
end
