function net = make_example_french3()
%MAKE_EXAMPLE_FRENCH3 Three-agent French example from the tutorial (Fig. 4).
%
%   net = MAKE_EXAMPLE_FRENCH3() reproduces the worked example of
%   Proskurnikov & Tempo, "A tutorial on modeling and analysis of dynamic
%   social networks. Part I", Example 1 / Eq. (5):
%
%       x1(k+1) = 1/2 x1 + 1/2 x2
%       x2(k+1) = 1/3 x1 + 1/3 x2 + 1/3 x3
%       x3(k+1) =         1/2 x2 + 1/2 x3
%
%   ANALYTIC GROUND TRUTH
%       The graph is strongly connected with positive self-weights, hence
%       aperiodic, so the model reaches consensus and the social power vector
%       is exactly
%
%           p_inf = [2/7, 3/7, 2/7]'
%
%   Use it as a unit-test fixture for SOCIAL_POWER and PREDICT_LIMIT_DEGROOT:
%   an implementation that cannot reproduce 2/7, 3/7, 2/7 is wrong.
%
%   See also MAKE_EXAMPLE_FJ4, SOCIAL_POWER, PREDICT_LIMIT_DEGROOT.

    W = [1/2, 1/2,   0; ...
         1/3, 1/3, 1/3; ...
           0, 1/2, 1/2];

    net = net_from_matrix(W, ...
        'Name', 'french3', ...
        'Labels', {'1'; '2'; '3'}, ...
        'Coords', [-1, 0; 0, 0; 1, 0], ...
        'Meta', struct( ...
            'source', 'Proskurnikov & Tempo (2017), Part I, Eq. (5) / Fig. 4', ...
            'notes',  'Analytic social power p_inf = [2/7 3/7 2/7]'''));
end
