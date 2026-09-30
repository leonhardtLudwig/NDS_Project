function Winf = limit_matrix(W, tol)
%LIMIT_MATRIX Limit of the powers of a stochastic matrix.
%
%   Winf = LIMIT_MATRIX(W) returns
%
%       W^inf = lim_{k->inf} W^k
%
%   computed by repeated squaring, so that W^(2^m) is reached in m products.
%
%   Winf = LIMIT_MATRIX(W, tol) uses the given convergence tolerance
%   (default 1e-14).
%
%   READING THE RESULT
%       rank(Winf) == 1   the model reaches CONSENSUS; then Winf = 1 p' and
%                         every row equals the social power vector.
%       rank(Winf) > 1    the model converges but to BLOCK consensus: several
%                         closed strong components, each agreeing internally.
%
%       x(inf) = Winf * x(0) in either case.
%
%   The limit exists iff every closed strong component is aperiodic. On a
%   periodic graph the iteration does not settle and this function errors.
%
%   Example
%       W = [1/2 1/2 0; 1/3 1/3 1/3; 0 1/2 1/2];
%       Winf = limit_matrix(W);
%       rank(Winf)                   % 1 -> consensus
%       Winf(1,:)                    % the social power vector
%
%   See also SOCIAL_POWER, GRAPH_SUMMARY.

    if nargin < 2, tol = 1e-14; end
    check_square(W, 'W');
    if ~is_row_stochastic(W)
        error('NDS:limit_matrix:notStochastic', ...
            'W must be row-stochastic. Use W = row_stochastic(A).');
    end

    Winf = W;
    settled = false;
    for m = 1:100
        next = Winf * Winf;                 % W^(2^m)

        % Each product loses about eps from every row sum, and squaring
        % compounds that as (1 - delta)^(2^m): after some sixty squarings the
        % whole matrix has decayed to 1e-46 and the test below passes because
        % everything is small, not because anything has converged. Rows are
        % renormalised so that the drift cannot accumulate.
        next = next ./ sum(next, 2);

        if norm(next - Winf, Inf) <= tol
            Winf = next;
            settled = true;
            break;
        end
        Winf = next;
    end

    % Squaring alone is not a sufficient test. On a cycle of period 4, for
    % instance, W^4 = I and I*I = I, so the iteration sits still at the
    % IDENTITY, which is not the limit. The genuine limit must also be a fixed
    % point of multiplication by W, so verify W^inf W = W^inf.
    if ~settled || norm(Winf * W - Winf, Inf) > 1e-8
        error('NDS:limit_matrix:noLimit', ...
            ['The powers of W do not settle: a closed strong component is ' ...
             'PERIODIC, so opinions oscillate and no limit exists. ' ...
             'Check GRAPH_SUMMARY(W).']);
    end
end
