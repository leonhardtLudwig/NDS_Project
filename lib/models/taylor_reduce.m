function [gamma, u] = taylor_reduce(B, s)
%TAYLOR_REDUCE Collapse Taylor's communication sources into per-agent prejudices.
%
%   [gamma, u] = TAYLOR_REDUCE(B, s) converts the original form of Taylor's
%   model, with m external communication sources,
%
%       xdot_i = sum_j a_ij (x_j - x_i) + sum_k b_ik (s_k - x_i)
%
%   into the equivalent reduced form with one prejudice per agent
%
%       xdot_i = sum_j a_ij (x_j - x_i) + gamma_i (u_i - x_i).
%
%   Inputs
%       B : n-by-m non-negative matrix of "persuasibility constants";
%           B(i,k) is how strongly source k acts on agent i
%       s : m-by-1 (or m-by-d) matrix of static source opinions
%
%   Outputs
%       gamma : n-by-1 total exposure of each agent, gamma_i = sum_k b_ik
%       u     : n-by-1 (or n-by-d) effective prejudice, the b-weighted mean
%               of the source opinions. Agents with gamma_i = 0 are free of
%               external influence and get u_i = 0, which is harmless because
%               their prejudice is multiplied by gamma_i = 0 in the dynamics.
%
%   The sources may be mass media, institutions, or the static leaders of a
%   containment-control problem; the reduction is exactly the one given in
%   Section 5.1 of Proskurnikov & Tempo, Part I.
%
%   See also SIM_TAYLOR, TAYLOR_MATRICES, PREDICT_LIMIT_TAYLOR.

    narginchk(2, 2);

    validateattributes(B, {'numeric'}, ...
        {'2d', 'real', 'finite', 'nonnegative'}, mfilename, 'B', 1);
    validateattributes(s, {'numeric'}, ...
        {'2d', 'real', 'finite'}, mfilename, 's', 2);

    [n, m] = size(B);

    if isvector(s) && numel(s) == m
        s = s(:);
    end
    if size(s, 1) ~= m
        error('NDS:taylorReduce:sizeMismatch', ...
            ['s must have one row per source: B is %d-by-%d, so s needs %d rows ' ...
             '(got %d).'], n, m, m, size(s, 1));
    end

    d = size(s, 2);
    gamma = sum(B, 2);
    u = zeros(n, d);

    active = gamma > 0;
    if any(active)
        u(active, :) = (B(active, :) * s) ./ gamma(active);
    end
end
