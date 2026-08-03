function [M, net] = network_matrix(input, field)
%NETWORK_MATRIX Accept either a network struct or a bare matrix.
%
%   [M, net] = NETWORK_MATRIX(input, field) lets every model and predictor
%   take either the network struct produced by NET_FROM_MATRIX or a plain
%   matrix, without repeating the unwrapping logic.
%
%   When input is a struct, M is input.(field) and net is the struct itself,
%   so the caller can store the provenance in its result. When input is a
%   matrix, M is that matrix and net is [].
%
%   field is 'W' for the discrete-time models (which need row-stochastic
%   weights) and 'A' for the continuous-time models (which use the raw
%   weights, whose row sums set the interaction rates).
%
%   See also NET_FROM_MATRIX, SIM_DEGROOT, SIM_ABELSON.

    narginchk(2, 2);

    if isstruct(input)
        if ~isscalar(input)
            error('NDS:networkMatrix:notScalarStruct', ...
                'A struct input must be a single network, not a struct array.');
        end
        if ~isfield(input, field)
            error('NDS:networkMatrix:missingField', ...
                ['A struct input must be a network built by NET_FROM_MATRIX; ' ...
                 'field ''%s'' is missing.'], field);
        end
        M = input.(field);
        net = input;
    else
        M = input;
        net = [];
    end
end
