function [tf, dt] = is_uniform_grid(t, relTol)
%IS_UNIFORM_GRID Test whether a time vector is uniformly spaced.
%
%   [tf, dt] = IS_UNIFORM_GRID(t) returns true when the spacing of t is
%   constant to within a relative tolerance of 1e-9, together with the common
%   step dt. When t is not uniform, dt is returned as NaN.
%
%   [tf, dt] = IS_UNIFORM_GRID(t, relTol) uses the given relative tolerance.
%
%   The continuous-time simulators exploit a uniform grid: the matrix
%   exponential of one step is computed once and then applied repeatedly,
%   which is both faster and more accurate than calling EXPM at every sample.
%
%   A vector with fewer than three points is trivially uniform.
%
%   See also SIM_ABELSON, SIM_TAYLOR.

    if nargin < 2 || isempty(relTol)
        relTol = 1e-9;
    end

    t = t(:).';
    if numel(t) < 2
        tf = true;
        dt = 0;
        return;
    end

    steps = diff(t);
    dt = steps(1);

    if numel(t) == 2
        tf = true;
        return;
    end

    scale = max(abs(dt), eps);
    if all(abs(steps - dt) <= relTol * scale)
        tf = true;
    else
        tf = false;
        dt = NaN;
    end
end
