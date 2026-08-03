function [net, u, x0] = make_example_fj4()
%MAKE_EXAMPLE_FJ4 Four-agent Friedkin-Johnsen example from the tutorial.
%
%   [net, u, x0] = MAKE_EXAMPLE_FJ4() reproduces the empirically derived
%   influence matrix of Friedkin & Johnsen (1999) as printed in Eq. (24) of
%   Proskurnikov & Tempo, Part I, together with the prejudice and initial
%   opinion vectors used for Fig. 6:
%
%       W  = [0.220 0.120 0.360 0.300
%             0.147 0.215 0.344 0.294
%             0     0     1     0
%             0.090 0.178 0.446 0.286]
%
%       u = x0 = [-1, -0.2, 0.6, 1]'
%
%   REPRODUCTION TARGET
%       Figure 6 of the tutorial shows three runs of the Friedkin-Johnsen
%       model on this network, obtained with three susceptibility matrices:
%
%           (a) Lambda = I                  -> reduces to French-DeGroot;
%                                              opinions reach CONSENSUS
%           (b) Lambda = I - diag(W)        -> Friedkin's coupling condition;
%                                              visible CLEAVAGE around the
%                                              stubborn agent 3
%           (c) Lambda = diag(1,0,0,1)      -> agents 2 and 3 stubborn;
%                                              agents 1 and 4 settle at
%                                              distinct nearby opinions
%                                              between them
%
%       Use FJ_LAMBDA(net.W, 'identity' | 'classic' | 'explicit') to build
%       these. Agent 3 is stubborn in every case, since row 3 of W is e_3.
%
%   This is the single most valuable validation fixture in the project:
%   reproducing a published figure exactly is the strongest evidence that the
%   implementation is correct.
%
%   See also FJ_LAMBDA, SIM_FRIEDKIN_JOHNSEN, MAKE_EXAMPLE_FRENCH3.

    W = [0.220, 0.120, 0.360, 0.300; ...
         0.147, 0.215, 0.344, 0.294; ...
         0.000, 0.000, 1.000, 0.000; ...
         0.090, 0.178, 0.446, 0.286];

    u  = [-1; -0.2; 0.6; 1];
    x0 = u;

    net = net_from_matrix(W, ...
        'Name', 'fj4', ...
        'Labels', {'1'; '2'; '3'; '4'}, ...
        'Coords', layout_polygon(4), ...
        'Meta', struct( ...
            'source', ['Friedkin & Johnsen (1999); reprinted as Eq. (24) in ' ...
                       'Proskurnikov & Tempo (2017), Part I'], ...
            'notes',  'Reproduction target for Fig. 6(a)-(c); agent 3 is stubborn'));
end
