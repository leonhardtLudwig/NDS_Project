function [W, u] = example_fj4()
%EXAMPLE_FJ4 The four-agent Friedkin-Johnsen example of the tutorial.
%
%   [W, u] = EXAMPLE_FJ4() returns the empirically identified influence
%   matrix of Friedkin & Johnsen (1999), reprinted as Eq. (24) of
%   Proskurnikov & Tempo, Part I, together with the prejudice vector used for
%   Figure 6:
%
%       W = [0.220 0.120 0.360 0.300
%            0.147 0.215 0.344 0.294
%            0     0     1     0
%            0.090 0.178 0.446 0.286]
%
%       u = x(0) = [-1, -0.2, 0.6, 1]'
%
%   REPRODUCTION TARGET
%       Figure 6 shows three runs on this network:
%           (a) lambda = 1              reduces to French-DeGroot: CONSENSUS
%           (b) lambda = 1 - diag(W)    Friedkin's coupling: visible CLEAVAGE
%           (c) lambda = [1 0 0 1]'     agents 2 and 3 stubborn
%       Agent 3 is stubborn in every case, since row 3 of W is e_3.
%
%   See also SIM_FRIEDKIN_JOHNSEN, TOTAL_INFLUENCE.

    W = [0.220, 0.120, 0.360, 0.300; ...
         0.147, 0.215, 0.344, 0.294; ...
         0.000, 0.000, 1.000, 0.000; ...
         0.090, 0.178, 0.446, 0.286];

    u = [-1; -0.2; 0.6; 1];
end
