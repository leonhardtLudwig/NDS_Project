function V = total_influence(W, lambda)
%TOTAL_INFLUENCE Friedkin-Johnsen total-influence matrix.
%
%   V = TOTAL_INFLUENCE(W, lambda) returns
%
%       V = (I - Lambda W)^{-1} (I - Lambda),      Lambda = diag(lambda)
%
%   the matrix mapping prejudices to final opinions in the Friedkin-Johnsen
%   model: x(inf) = V u.
%
%   V IS ROW-STOCHASTIC, so every final opinion is a convex combination of
%   the prejudices: disagreement is persistent but BOUNDED -- cleavage, never
%   runaway extremism.
%
%   THE RANK IS THE POINT
%       French-DeGroot     lim W^k = 1 p'      RANK ONE   -> consensus
%       Friedkin-Johnsen   x(inf) = V u,  V generically FULL RANK
%                                                     -> every agent keeps a
%                                                        trace of its own
%                                                        prejudice
%       Both limit operators are row-stochastic; the RANK separates consensus
%       from cleavage. Compare rank(V) with rank(limit_matrix(W)).
%
%   With lambda = alpha for all agents, V_alpha interpolates continuously
%   between V_0 = I (everyone frozen at their prejudice) and V_1 = 1 p'
%   (consensus), and reproduces PageRank with alpha = 1 - m.
%
%   The system is solved with the backslash operator, never by forming an
%   explicit inverse. (I - Lambda W) becomes ill-conditioned as lambda
%   approaches 1, which is exactly where the model degenerates to the
%   marginally stable French-DeGroot dynamics.
%
%   Example
%       W = [0.5 0.5; 0.5 0.5];
%       total_influence(W, [0.5; 1])       % [1 0; 1 0]      rank 1
%       total_influence(W, [0.25; 0.75])   % [15/16 1/16; 9/16 7/16]
%
%   See also FJ_EQUILIBRIUM, SIM_FRIEDKIN_JOHNSEN, SOCIAL_POWER.

    n      = check_square(W, 'W');
    lambda = check_vector(lambda, n, 'lambda');

    if ~is_row_stochastic(W)
        error('NDS:total_influence:notStochastic', ...
            'W must be row-stochastic. Use W = row_stochastic(A).');
    end
    if any(lambda < 0) || any(lambda > 1)
        error('NDS:total_influence:badLambda', 'lambda must lie in [0,1].');
    end

    LW = lambda .* W;                     % Lambda * W
    if max(abs(eig(LW))) >= 1 - 1e-12
        error('NDS:total_influence:notStable', ...
            ['rho(Lambda W) is not below 1, so V does not exist: some agents are ' ...
             'never reached by a prejudice (or lambda = 1, which is the ' ...
             'French-DeGroot model). Check PREJUDICE_REACH(W, lambda < 1).']);
    end

    V = (eye(n) - LW) \ diag(1 - lambda);
end
