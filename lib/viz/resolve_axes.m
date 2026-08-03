function ax = resolve_axes(candidate)
%RESOLVE_AXES Return the axes a plotting function should draw into.
%
%   ax = RESOLVE_AXES(candidate) returns the axes to draw into: the supplied
%   handle when one is given, otherwise the current axes.
%
%   Every plotting function in this project accepts an 'Axes' option so that
%   figures can be composed into subplots or tiled layouts by the Live
%   Scripts, instead of each function seizing control of a new figure.
%
%   The axes are prepared with NEWPLOT, which is the documented mechanism for
%   a well-behaved MATLAB plotting function. This gives the conventional
%   semantics that users already expect:
%
%       plot_opinions(res)                  draws into the current figure,
%                                           creating one only if none exists
%       figure; plot_opinions(res)          draws into that specific figure
%       hold(ax,'on'); plot_opinions(...)   overlays instead of replacing
%       plot_opinions(res,'Axes',nexttile)  composes into a tiled layout
%
%   Returning a brand-new figure unconditionally would break all four.
%
%   See also NEWPLOT, PLOT_OPINIONS, PLOT_NETWORK, PLOT_SPECTRUM.

    if nargin >= 1 && ~isempty(candidate)
        if ~(isscalar(candidate) && isgraphics(candidate) && ...
                isa(candidate, 'matlab.graphics.axis.Axes'))
            error('NDS:resolveAxes:invalidHandle', ...
                'The ''Axes'' option must be a single valid axes handle.');
        end
        ax = newplot(candidate);
        return;
    end

    ax = newplot();
end
