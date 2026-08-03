function net = make_ring(n, varargin)
%MAKE_RING Ring network -- the canonical periodicity example.
%
%   net = MAKE_RING(n) builds the directed cycle on n agents in which agent i
%   listens only to agent i-1 (agent 1 listens to agent n).
%
%   Name-value options
%       'Type'        'directed'  (default) each agent copies its predecessor
%                     'symmetric' each agent averages both neighbours
%       'SelfWeight'  s in [0,1), weight each agent keeps on itself
%                     (default 0). Any s > 0 makes the graph aperiodic.
%
%   Why this network matters
%       * 'directed' with s = 0 gives a PERMUTATION matrix: strongly
%         connected, doubly stochastic, but PERIODIC with period n. The
%         French-DeGroot model never converges -- the opinion vector rotates
%         forever. This is the counterexample showing that strong
%         connectivity alone is NOT sufficient for consensus.
%       * 'symmetric' with s = 0 is periodic with period 2 exactly when n is
%         EVEN (the cycle is then bipartite), and aperiodic when n is odd.
%         Convergence therefore depends on the parity of n.
%       * Any s > 0 introduces self-loops, making the graph aperiodic, so the
%         model converges -- and because the matrix stays doubly stochastic,
%         it converges to the plain AVERAGE of the initial opinions.
%       * The Abelson model on the same graph always converges: periodicity
%         is an artefact of synchronous discrete-time updating, not a
%         property of the network.
%
%   See also MAKE_STAR, MAKE_PATH, MAKE_COMPLETE, MAKE_TWO_COMMUNITIES.

    validateattributes(n, {'numeric'}, ...
        {'scalar', 'integer', '>=', 2}, mfilename, 'n', 1);

    opts = parse_options(struct( ...
        'Type',       'directed', ...
        'SelfWeight', 0), varargin, mfilename);

    type = validatestring(opts.Type, {'directed', 'symmetric'}, ...
        mfilename, 'Type');
    s = opts.SelfWeight;
    validateattributes(s, {'numeric'}, ...
        {'scalar', 'real', '>=', 0, '<', 1}, mfilename, 'SelfWeight');

    A = zeros(n);
    prev = [n, 1:n-1];          % predecessor of each agent
    next = [2:n, 1];            % successor of each agent

    switch type
        case 'directed'
            for ii = 1:n
                A(ii, prev(ii)) = 1 - s;
            end
        case 'symmetric'
            for ii = 1:n
                A(ii, prev(ii)) = A(ii, prev(ii)) + (1 - s) / 2;
                A(ii, next(ii)) = A(ii, next(ii)) + (1 - s) / 2;
            end
    end

    if s > 0
        A = A + s * eye(n);
    end

    name = sprintf('ring-%s-n%d', type, n);
    if s > 0
        name = sprintf('%s-self%.2g', name, s);
    end

    net = net_from_matrix(A, ...
        'Name', name, ...
        'Coords', layout_polygon(n), ...
        'Meta', struct( ...
            'source', 'synthetic', ...
            'notes',  sprintf('%s ring, self-weight %g', type, s)));
end
