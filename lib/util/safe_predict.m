function [xinf, info] = safe_predict(doPredict, predictFcn, varargin)
%SAFE_PREDICT Evaluate a limit predictor without letting it break a simulation.
%
%   [xinf, info] = SAFE_PREDICT(doPredict, predictFcn, args...) calls
%   predictFcn(args{:}) and returns its predicted limit, or [] when
%   doPredict is false or the prediction fails.
%
%   info.status  : 'ok' | 'skipped' | 'failed'
%   info.message : the error message when status is 'failed'
%
%   Every simulator reports the theoretical limit alongside the simulated
%   trajectory, so that "theory predicts, simulation confirms" is the default
%   workflow rather than an extra step. A predictor may legitimately fail --
%   for example on a periodic graph, where no limit exists -- and that must
%   never prevent the trajectory itself from being returned.
%
%   See also PREDICT_LIMIT_DEGROOT, PREDICT_LIMIT_ABELSON, PREDICT_LIMIT_TAYLOR,
%   PREDICT_LIMIT_FJ.

    narginchk(2, Inf);

    info = struct('status', 'skipped', 'message', '');
    xinf = [];

    if ~doPredict
        return;
    end

    try
        warnState = warning('off', 'all');
        cleanup = onCleanup(@() warning(warnState));
        xinf = predictFcn(varargin{:});
        info.status = 'ok';
    catch err
        xinf = [];
        info.status = 'failed';
        info.message = err.message;
    end
end
