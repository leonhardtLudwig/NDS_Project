function t = validate_time_vector(t, name)
%VALIDATE_TIME_VECTOR Check and canonicalise a continuous-time sample vector.
%
%   t = VALIDATE_TIME_VECTOR(t) verifies that t is a real, finite,
%   non-decreasing vector with at least one entry, and returns it as a row
%   vector.
%
%   t = VALIDATE_TIME_VECTOR(t, name) uses name in the error messages.
%
%   Following the convention of MATLAB's ODE solvers, the initial condition
%   supplied to a continuous-time simulator is the state at t(1), not
%   necessarily at time zero.
%
%   See also SIM_ABELSON, SIM_TAYLOR, IS_UNIFORM_GRID.

    if nargin < 2 || isempty(name)
        name = 't';
    end

    validateattributes(t, {'numeric'}, ...
        {'vector', 'real', 'finite', 'nonempty'}, mfilename, name);

    t = double(t(:).');

    if any(diff(t) < 0)
        error('NDS:validate:timeNotIncreasing', ...
            '%s must be non-decreasing.', name);
    end
end
