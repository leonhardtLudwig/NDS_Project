function net = make_path(n, varargin)
%MAKE_PATH Directed chain -- minimal rooted, not strongly connected network.
%
%   net = MAKE_PATH(n) builds the directed path on n agents in which agent i
%   listens to agent i-1, and agent 1 listens only to itself.
%
%   Name-value options
%       'SelfWeight'  s in [0,1) kept by agents 2..n (default 0). Agent 1
%                     always has a pure self-loop, since it is the source.
%
%   Why this network matters
%       * It is ROOTED but NOT strongly connected -- the smallest example
%         separating those two conditions. Agent 1 is a root that reaches
%         everyone; nobody reaches agent 1.
%       * Agent 1 is stubborn, so the group converges to x1(0) and the social
%         power vector is e_1: every other agent's initial opinion is
%         completely forgotten.
%       * Influence propagates but never returns, and mixing is slow
%         (O(n^2)), which makes it a good convergence-rate illustration.
%       * For Taylor and Friedkin-Johnsen, anchoring the head versus the tail
%         of the chain gives completely different limits.
%
%   See also MAKE_RING, MAKE_STAR, MAKE_TWO_COMMUNITIES.

    validateattributes(n, {'numeric'}, ...
        {'scalar', 'integer', '>=', 2}, mfilename, 'n', 1);

    opts = parse_options(struct('SelfWeight', 0), varargin, mfilename);
    s = opts.SelfWeight;
    validateattributes(s, {'numeric'}, ...
        {'scalar', 'real', '>=', 0, '<', 1}, mfilename, 'SelfWeight');

    A = zeros(n);
    A(1, 1) = 1;                                   % source
    for ii = 2:n
        A(ii, ii - 1) = 1 - s;
        if s > 0
            A(ii, ii) = s;
        end
    end

    coords = [(0:n-1).', zeros(n, 1)];

    net = net_from_matrix(A, ...
        'Name', sprintf('path-n%d', n), ...
        'Coords', coords, ...
        'Meta', struct( ...
            'source', 'synthetic', ...
            'notes',  sprintf('directed chain, agent 1 is the source, self-weight %g', s)));
end
