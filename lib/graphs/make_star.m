function net = make_star(n, varargin)
%MAKE_STAR Star network -- the canonical centralisation example.
%
%   net = MAKE_STAR(n) builds a star on n agents with agent 1 as the hub.
%
%   Name-value options
%       'Type'        'hub-source'    (default) leaves listen to the hub;
%                                     the hub listens only to itself
%                     'bidirectional' leaves listen to the hub and the hub
%                                     listens uniformly to all leaves
%       'Hub'         index of the hub agent (default 1)
%       'SelfWeight'  s in [0,1) kept by every non-source agent (default 0)
%
%   Why this network matters
%       * 'hub-source': the hub is a STUBBORN ROOT. It reaches everyone and
%         nobody reaches it, so the whole group converges to the hub's
%         initial opinion and the social power vector is a unit vector on the
%         hub. Maximal centralisation.
%       * 'bidirectional' with s = 0: strongly connected but PERIODIC with
%         period 2 -- opinions oscillate. Adding any self-weight fixes it.
%       * It is the cleanest testbed for stubborn-agent placement in the
%         Friedkin-Johnsen model: anchoring the hub versus anchoring a leaf
%         produces dramatically different total-influence matrices V.
%
%   See also MAKE_RING, MAKE_PATH, MAKE_COMPLETE, FJ_MATRICES.

    validateattributes(n, {'numeric'}, ...
        {'scalar', 'integer', '>=', 2}, mfilename, 'n', 1);

    opts = parse_options(struct( ...
        'Type',       'hub-source', ...
        'Hub',        1, ...
        'SelfWeight', 0), varargin, mfilename);

    type = validatestring(opts.Type, {'hub-source', 'bidirectional'}, ...
        mfilename, 'Type');
    hub = opts.Hub;
    validateattributes(hub, {'numeric'}, ...
        {'scalar', 'integer', '>=', 1, '<=', n}, mfilename, 'Hub');
    s = opts.SelfWeight;
    validateattributes(s, {'numeric'}, ...
        {'scalar', 'real', '>=', 0, '<', 1}, mfilename, 'SelfWeight');

    leaves = setdiff(1:n, hub);
    A = zeros(n);

    % Every leaf listens to the hub (and possibly to itself).
    A(leaves, hub) = 1 - s;
    if s > 0
        for ii = leaves
            A(ii, ii) = s;
        end
    end

    switch type
        case 'hub-source'
            A(hub, hub) = 1;                       % hub ignores everyone
        case 'bidirectional'
            A(hub, leaves) = (1 - s) / numel(leaves);
            if s > 0
                A(hub, hub) = s;
            end
    end

    % Hub at the centre, leaves on a circle around it.
    coords = zeros(n, 2);
    coords(hub, :) = [0, 0];
    coords(leaves, :) = layout_polygon(numel(leaves));

    name = sprintf('star-%s-n%d', type, n);
    if s > 0
        name = sprintf('%s-self%.2g', name, s);
    end

    net = net_from_matrix(A, ...
        'Name', name, ...
        'Coords', coords, ...
        'Meta', struct( ...
            'source', 'synthetic', ...
            'notes',  sprintf('%s star, hub %d, self-weight %g', type, hub, s)));
end
