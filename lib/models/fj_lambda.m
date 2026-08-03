function lambda = fj_lambda(W, preset, param)
%FJ_LAMBDA Build a Friedkin-Johnsen susceptibility vector from a preset.
%
%   lambda = FJ_LAMBDA(W, preset, param) returns the n-by-1 vector of
%   susceptibilities lambda_i in [0,1] used by the Friedkin-Johnsen model
%
%       x(k+1) = diag(lambda)*W*x(k) + (I - diag(lambda))*u.
%
%   W may be a matrix or a network struct.
%
%   Presets
%       'identity'  lambda = 1 for everyone. The anchoring term vanishes and
%                   the model reduces EXACTLY to French-DeGroot.
%       'classic'   lambda = 1 - diag(W), Friedkin & Johnsen's own coupling
%                   condition: an agent's attachment to its prejudice equals
%                   its self-weight. This is the empirically identified form,
%                   and it makes an agent with w_ii = 1 totally stubborn.
%       'uniform'   lambda = param for everyone, param = alpha in [0,1].
%                   The family {V_alpha} interpolates continuously between
%                   V_0 = I (everyone frozen at their prejudice) and
%                   V_1 = 1*p' (consensus), and reproduces PageRank with
%                   alpha = 1 - m and uniform prejudice.
%       'stubborn'  lambda = 1 everywhere except the agent indices in param,
%                   which get lambda = 0 and are therefore TOTALLY STUBBORN.
%
%   Examples reproducing Fig. 6 of Proskurnikov & Tempo, Part I:
%       net = make_example_fj4();
%       lambdaA = fj_lambda(net, 'identity');           % Fig. 6(a) consensus
%       lambdaB = fj_lambda(net, 'classic');            % Fig. 6(b) cleavage
%       lambdaC = fj_lambda(net, 'stubborn', [2 3]);    % Fig. 6(c)
%
%   See also FJ_MATRICES, SIM_FRIEDKIN_JOHNSEN, MAKE_EXAMPLE_FJ4.

    narginchk(2, 3);
    if nargin < 3
        param = [];
    end

    W = network_matrix(W, 'W');
    n = validate_row_stochastic(W, 'W');

    preset = validatestring(preset, ...
        {'identity', 'classic', 'uniform', 'stubborn'}, mfilename, 'preset', 2);

    switch preset
        case 'identity'
            lambda = ones(n, 1);

        case 'classic'
            lambda = 1 - diag(W);

        case 'uniform'
            if isempty(param)
                error('NDS:fjLambda:missingAlpha', ...
                    'Preset ''uniform'' requires alpha as the third argument.');
            end
            validateattributes(param, {'numeric'}, ...
                {'scalar', 'real', '>=', 0, '<=', 1}, mfilename, 'alpha', 3);
            lambda = repmat(double(param), n, 1);

        case 'stubborn'
            if isempty(param)
                error('NDS:fjLambda:missingIndices', ...
                    ['Preset ''stubborn'' requires the indices of the totally ' ...
                     'stubborn agents as the third argument.']);
            end
            validateattributes(param, {'numeric'}, ...
                {'vector', 'integer', '>=', 1, '<=', n}, mfilename, 'indices', 3);
            lambda = ones(n, 1);
            lambda(param) = 0;
    end

    % Guard against round-off in 1 - diag(W).
    lambda = min(max(lambda, 0), 1);
end
