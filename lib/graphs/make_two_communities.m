function net = make_two_communities(blockSizes, beta, varargin)
%MAKE_TWO_COMMUNITIES Two dense blocks joined by weak bridges.
%
%   net = MAKE_TWO_COMMUNITIES(blockSizes, beta) builds a network of two
%   fully connected communities coupled by a small number of weak links of
%   raw weight beta.
%
%   blockSizes is either a scalar (both blocks that size) or a two-element
%   vector [n1 n2]. beta >= 0 is the raw weight of each bridge, relative to
%   the within-block weight of 1.
%
%   Name-value options
%       'Bridges'  number of bridge pairs (default 1). Bridge k connects
%                  agent (n1 - k + 1) of block 1 with agent k of block 2, in
%                  both directions.
%
%   Why this network matters
%       This is the MINIMAL structure that separates consensus from cleavage,
%       and the only way to exhibit the community cleavage problem inside the
%       averaging models.
%
%       * beta = 0 gives TWO CLOSED strong components. The graph is not
%         rooted, so French-DeGroot and Abelson converge to BLOCK CONSENSUS:
%         each community agrees internally and the two disagree forever.
%         Disagreement here is topological, not behavioural.
%       * beta > 0 restores rootedness, so consensus is recovered -- but with
%         a TIMESCALE SEPARATION: fast agreement within blocks, slow drift
%         between them. This shows up as a plateau in the trajectory plot and
%         as a small spectral gap.
%
%       Sweeping beta and, separately, sweeping the Friedkin-Johnsen
%       parameter alpha shows that weak coupling and stubbornness produce
%       visually similar cleavage by mathematically different mechanisms: a
%       transient plateau in one case, a genuine equilibrium in the other.
%
%   See also MAKE_COMPLETE, MAKE_RING, SIM_FRIEDKIN_JOHNSEN.

    narginchk(1, Inf);
    if nargin < 2 || isempty(beta)
        beta = 0;
    end

    validateattributes(blockSizes, {'numeric'}, ...
        {'vector', 'integer', '>=', 2}, mfilename, 'blockSizes', 1);
    if isscalar(blockSizes)
        blockSizes = [blockSizes, blockSizes];
    end
    if numel(blockSizes) ~= 2
        error('NDS:makeTwoCommunities:blockCount', ...
            'blockSizes must be a scalar or a two-element vector (got %d elements).', ...
            numel(blockSizes));
    end
    validateattributes(beta, {'numeric'}, ...
        {'scalar', 'real', 'nonnegative', 'finite'}, mfilename, 'beta', 2);

    opts = parse_options(struct('Bridges', 1), varargin, mfilename);
    nBridges = opts.Bridges;
    maxBridges = min(blockSizes);
    validateattributes(nBridges, {'numeric'}, ...
        {'scalar', 'integer', '>=', 0, '<=', maxBridges}, mfilename, 'Bridges');

    n1 = blockSizes(1);
    n2 = blockSizes(2);
    n  = n1 + n2;

    block1 = 1:n1;
    block2 = n1 + (1:n2);

    % Dense within each block (no self-loops), weight 1.
    A = zeros(n);
    A(block1, block1) = ones(n1) - eye(n1);
    A(block2, block2) = ones(n2) - eye(n2);

    % Weak bidirectional bridges.
    for k = 1:nBridges
        a = block1(n1 - k + 1);
        b = block2(k);
        A(a, b) = beta;
        A(b, a) = beta;
    end

    % Two visually separated clusters.
    coords = zeros(n, 2);
    coords(block1, :) = layout_polygon(n1, 1, [-2, 0]);
    coords(block2, :) = layout_polygon(n2, 1, [ 2, 0]);

    community = [ones(n1, 1); 2 * ones(n2, 1)];

    net = net_from_matrix(A, ...
        'Name', sprintf('two-communities-%d+%d-beta%.3g', n1, n2, beta), ...
        'Coords', coords, ...
        'Meta', struct( ...
            'source',    'synthetic', ...
            'community', community, ...
            'beta',      beta, ...
            'notes',     sprintf(['two complete blocks of size %d and %d, ' ...
                                  '%d bridge pair(s) of weight %g'], ...
                                  n1, n2, nBridges, beta)));
end
