function d = containment_distance(P, S)
%CONTAINMENT_DISTANCE Distance from agent positions to the leaders' convex hull.
%
%   d = CONTAINMENT_DISTANCE(P, S) takes the k-by-2 matrix P of agent
%   positions and the m-by-2 matrix S of leader positions and returns the
%   k-vector of Euclidean distances from each agent to
%
%       conv(S) = { sum_k w_k s_k : w >= 0, sum_k w_k = 1 }
%
%   The distance is 0 for an agent inside the hull or on its boundary, so
%   d -> 0 is exactly the containment objective of Theorem 3.2.
%
%   WHY A DISTANCE AND NOT A YES/NO TEST
%       Whether an agent is inside is a single bit, and it says nothing while
%       the agent is still on its way. The distance is a convergence metric:
%       plotted against time it decays to zero for every P-dependent agent and
%       flattens at a positive value for a P-independent one, which is the
%       numerical signature of the equivalence failing.
%
%   Planar positions only. Containment control is usually posed in the plane
%   and the hull can then be built exactly from CONVHULL and INPOLYGON,
%   without a quadratic program. Degenerate leader sets are handled: a single
%   leader gives the distance to that point, and collinear leaders give the
%   distance to the segment they span.
%
%   Example
%       S = [0 0; 6 0; 4 5];
%       containment_distance([3 2; 10 10], S)     % [0; ...]
%
%   See also CONVHULL, INPOLYGON, SIM_TAYLOR, PREJUDICE_REACH.

    if size(P, 2) ~= 2 || size(S, 2) ~= 2
        error('NDS:containment_distance:notPlanar', ...
            'P and S must have two columns: this is the planar case.');
    end
    if isempty(S)
        error('NDS:containment_distance:noLeaders', 'S must contain at least one leader.');
    end

    k = size(P, 1);
    d = zeros(k, 1);

    if size(S, 1) == 1                                  % a single leader
        d = vecnorm(P - S, 2, 2);
        return;
    end

    hull = hull_indices(S);

    if numel(hull) < 3                                  % collinear leaders
        for i = 1:k
            d(i) = min_edge_distance(P(i,:), S(hull, :), false);
        end
        return;
    end

    V = S(hull, :);
    inside = inpolygon(P(:,1), P(:,2), V(:,1), V(:,2));

    for i = 1:k
        if inside(i)
            d(i) = 0;
        else
            d(i) = min_edge_distance(P(i,:), V, true);
        end
    end
end

% -------------------------------------------------------------------------
function hull = hull_indices(S)
%HULL_INDICES Vertices of conv(S), falling back to the two extreme points
%   when the leaders are collinear and CONVHULL cannot triangulate them.

    try
        hull = convhull(S(:,1), S(:,2));
        hull = hull(1:end-1);                           % drop the repeated first vertex
    catch
        [~, lo] = min(S(:,1) * 1e6 + S(:,2));           % lexicographic extremes
        [~, hi] = max(S(:,1) * 1e6 + S(:,2));
        hull = [lo; hi];
    end
end

% -------------------------------------------------------------------------
function d = min_edge_distance(p, V, closed)
%MIN_EDGE_DISTANCE Distance from p to the polygon or polyline through V.

    m = size(V, 1);
    if closed
        pairs = [(1:m).', [2:m, 1].'];
    else
        pairs = [(1:m-1).', (2:m).'];
    end

    d = Inf;
    for e = 1:size(pairs, 1)
        a = V(pairs(e,1), :);
        b = V(pairs(e,2), :);
        ab = b - a;
        len2 = ab * ab.';
        if len2 == 0
            proj = a;
        else
            s = max(0, min(1, ((p - a) * ab.') / len2));
            proj = a + s * ab;
        end
        d = min(d, norm(p - proj));
    end
end
