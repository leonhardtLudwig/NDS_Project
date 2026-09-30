function W = example_french3()
%EXAMPLE_FRENCH3 The three-agent French example of the tutorial.
%
%   W = EXAMPLE_FRENCH3() returns the influence matrix of Example 1.3
%   (Proskurnikov & Tempo, Part I, Eq. 5 and Fig. 4):
%
%       x1(k+1) = 1/2 x1 + 1/2 x2
%       x2(k+1) = 1/3 x1 + 1/3 x2 + 1/3 x3
%       x3(k+1) =         1/2 x2 + 1/2 x3
%
%   ANALYTIC GROUND TRUTH
%       The graph is strongly connected with positive self-weights, hence
%       aperiodic, so the model reaches consensus with social power exactly
%
%           p = [2/7, 3/7, 2/7]'
%
%   The matrix is short enough to type out in a notebook, and doing so is
%   often clearer than calling this function. It is provided so the citation
%   and the analytic answer live somewhere permanent.
%
%   See also SOCIAL_POWER, EXAMPLE_FJ4.

    W = [1/2, 1/2,   0; ...
         1/3, 1/3, 1/3; ...
           0, 1/2, 1/2];
end
