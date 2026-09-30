function c = influence_centrality(W, lambda)
%INFLUENCE_CENTRALITY Friedkin's influence centrality of the agents.
%
%   c = INFLUENCE_CENTRALITY(W, lambda) returns
%
%       c = (1/n) V' 1 ,      V = TOTAL_INFLUENCE(W, lambda)           (E4.2)
%
%   the vector whose i-th entry is the MEAN weight of agent i's initial
%   opinion across the final opinions of the whole group, when the prejudices
%   are the initial opinions, u = x(0), and the model is asymptotically
%   stable. V is row-stochastic, so c is non-negative and sums to one.
%
%   lambda may be a scalar, applied to every agent.
%
%   WHAT IT GENERALISES
%       French's social power assumes the group reaches CONSENSUS, and
%       measures the weight of x_i(0) in that single common value. The
%       Friedkin-Johnsen model does not reach consensus, so there is no single
%       final opinion to weigh against; c averages agent i's weight over all
%       the agents' final opinions instead.
%
%   THE FAMILY IT GENERATES
%       With lambda = alpha for every agent, c(alpha) sweeps a whole class of
%       centrality measures:
%
%           alpha = 0     V = I, so c = 1/n: influence is shared equally
%           alpha -> 1    c tends to French's social power SOCIAL_POWER(W),
%                         when that exists
%           alpha = 1 - m PAGERANK with teleportation probability m; the
%                         damped random surfer of (M4.2) is the dual chain of
%                         the Friedkin-Johnsen model with Lambda = (1-m) I
%
%       So the damping factor is not a numerical fudge: it is the agents'
%       susceptibility, and it controls how far influence is allowed to
%       propagate along the graph before it is discounted.
%
%   Example
%       W = row_stochastic([1 0 1 1 0; 1 0 0 0 0; 0 1 0 0 1; 0 1 0 0 0; 0 1 0 0 0]);
%       influence_centrality(W, 0.85)          % PageRank, m = 0.15
%       social_power(W)                        % the limit as lambda -> 1
%
%   See also TOTAL_INFLUENCE, SOCIAL_POWER, SIM_FRIEDKIN_JOHNSEN.

    n = check_square(W, 'W');
    if isscalar(lambda)
        lambda = lambda * ones(n, 1);
    end
    lambda = check_vector(lambda, n, 'lambda');

    V = total_influence(W, lambda);        % validates W, lambda and stability
    c = (V.' * ones(n, 1)) / n;
end
