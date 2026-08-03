function U = match_input_dimension(u, n, d, name)
%MATCH_INPUT_DIMENSION Bring an exogenous input to the state's dimensions.
%
%   U = MATCH_INPUT_DIMENSION(u, n, d, name) validates the prejudice (or
%   other exogenous input) u against a state of n agents and opinion
%   dimension d, and returns it as an n-by-d matrix.
%
%   A scalar or n-vector input is accepted for any d and replicated across
%   the opinion dimensions, which keeps the common scalar case terse while
%   remaining unambiguous for vector opinions.
%
%   See also PREPARE_STATE, SIM_TAYLOR, SIM_FRIEDKIN_JOHNSEN.

    narginchk(3, 4);
    if nargin < 4 || isempty(name)
        name = 'u';
    end

    [U, du] = prepare_state(u, n, name);

    if du == d
        return;
    end
    if du == 1
        U = repmat(U, 1, d);
        return;
    end

    error('NDS:validate:inputDimensionMismatch', ...
        ['%s has opinion dimension %d but the state has dimension %d. ' ...
         'Supply either a matching n-by-%d matrix or a single column.'], ...
        name, du, d, d);
end
