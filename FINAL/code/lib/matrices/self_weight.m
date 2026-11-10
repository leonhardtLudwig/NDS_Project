function A = self_weight(A, t)
%SELF_WEIGHT Give agent 1 a self-weight t, leaving every other row alone.
%
%   A = SELF_WEIGHT(A, t) replaces ONLY the first row of the row-stochastic
%   matrix A by
%
%       a_1(t)' = (1 - t) a_1' + t e_1'
%
%   so that agent 1 keeps a fraction t of its current opinion and
%   redistributes the rest with its original weights. The result is again
%   row-stochastic.
%
%   The two ends of the family are
%       t = 0   the original network, agent 1 like everybody else
%       t = 1   agent 1 stubborn: a_1' = e_1', its opinion never moves
%
%   Example
%       self_weight(directed_cycle(3), 0.5)
%
%   See also DIRECTED_CYCLE, BIDIRECTIONAL_RING, SOCIAL_POWER.

    A(1,:) = (1 - t) * A(1,:);
    A(1,1) = A(1,1) + t;
end
