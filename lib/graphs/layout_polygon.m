function coords = layout_polygon(n, radius, center)
%LAYOUT_POLYGON Coordinates of n points on a regular polygon.
%
%   coords = LAYOUT_POLYGON(n) returns an n-by-2 matrix of (x,y) coordinates
%   placing n nodes on a unit circle, node 1 at the top and the remaining
%   nodes ordered clockwise.
%
%   coords = LAYOUT_POLYGON(n, radius) scales the circle (default 1).
%   coords = LAYOUT_POLYGON(n, radius, center) recentres it (default [0 0]).
%
%   A deterministic layout keeps figures reproducible across runs, which
%   matters when the same network is plotted in several sections of a report.
%
%   See also NET_FROM_MATRIX, PLOT_NETWORK.

    narginchk(1, 3);
    validateattributes(n, {'numeric'}, ...
        {'scalar', 'integer', 'nonnegative'}, mfilename, 'n', 1);
    if nargin < 2 || isempty(radius)
        radius = 1;
    end
    if nargin < 3 || isempty(center)
        center = [0, 0];
    end
    validateattributes(radius, {'numeric'}, ...
        {'scalar', 'real', 'positive', 'finite'}, mfilename, 'radius', 2);
    validateattributes(center, {'numeric'}, ...
        {'vector', 'numel', 2, 'real', 'finite'}, mfilename, 'center', 3);

    if n == 0
        coords = zeros(0, 2);
        return;
    end
    if n == 1
        coords = center(:).';
        return;
    end

    % Clockwise from the top so that node order matches the visual order.
    theta = pi/2 - (0:n-1).' * (2*pi / n);
    coords = [center(1) + radius * cos(theta), ...
              center(2) + radius * sin(theta)];
end
