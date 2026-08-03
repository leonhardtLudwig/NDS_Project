function res = pack_result(model, t, traj, xinf, params, net)
%PACK_RESULT Assemble the uniform result structure returned by every model.
%
%   res = PACK_RESULT(model, t, traj, xinf, params, net) builds the structure
%   that all four simulators return, so that plotting, analysis and
%   comparison code can stay model-agnostic.
%
%   Inputs
%       model  : 'degroot' | 'abelson' | 'taylor' | 'fj'
%       t      : 1-by-K vector of sample times (0:K-1 for discrete models)
%       traj   : n-by-d-by-K trajectory tensor
%       xinf   : n-by-d predicted limit, or [] when none is available
%       params : struct of the parameters needed to reproduce the run
%       net    : the network struct used, or [] if the model was called with
%                raw matrices
%
%   Output fields
%       res.model, res.t, res.X, res.d, res.n, res.xinf, res.params, res.net
%
%   res.X is squeezed to an n-by-K matrix for scalar opinions (d == 1) and
%   left as n-by-d-by-K otherwise. res.d always records the true dimension,
%   so downstream code can branch on it rather than on the array shape.
%
%   See also PREPARE_STATE.

    narginchk(5, 6);
    if nargin < 6
        net = [];
    end

    [n, d, K] = size(traj);

    if numel(t) ~= K
        error('NDS:packResult:sizeMismatch', ...
            'Time vector has %d entries but the trajectory has %d samples.', ...
            numel(t), K);
    end

    res = struct();
    res.model  = model;
    res.t      = t(:).';
    res.n      = n;
    res.d      = d;
    if d == 1
        res.X = reshape(traj, n, K);
    else
        res.X = traj;
    end
    if isempty(xinf)
        res.xinf = NaN(n, d);
    else
        res.xinf = xinf;
    end
    res.params = params;
    res.net    = net;
end
