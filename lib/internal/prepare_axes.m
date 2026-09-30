function ax = prepare_axes()
%PREPARE_AXES Return the axes to draw into, cleared unless HOLD is on.
%
%   ax = PREPARE_AXES() returns the current axes, creating one if necessary.
%   Unless the caller has explicitly issued HOLD ON, the axes are fully reset
%   first: existing content, and any colourbar or legend attached to them, are
%   removed, and axes properties are restored to their defaults.
%
%   WHY THE FULL RESET
%       A plotting function must not inherit the state left by the previous
%       one. PLOT_GRAPH ends with AXIS OFF and AXIS EQUAL; without a reset, a
%       PLOT_OPINIONS call into the same axes would draw its trajectories on
%       top of the graph, with no visible ticks and a square aspect ratio.
%       In a Live Script, where consecutive cells share the current figure,
%       that happens on the very next cell.
%
%       CLA alone is not enough: it removes children but keeps axes
%       properties, so 'axis off' would persist. CLA ... RESET is what clears
%       both.
%
%   HOLD ON is still honoured, so deliberate overlays keep working:
%
%       plot_opinions(X1); hold on; plot_opinions(X2);
%
%   See also NEWPLOT, CLA, PLOT_GRAPH, PLOT_OPINIONS.

    ax = gca;

    if ishold(ax)
        return;                       % the caller asked to overlay
    end

    figureHandle = ancestor(ax, 'figure');

    % Colourbars and legends are children of the FIGURE, not of the axes, so
    % CLA does not remove them.
    decorations = [findall(figureHandle, 'Type', 'ColorBar'); ...
                   findall(figureHandle, 'Type', 'Legend')];
    for k = 1:numel(decorations)
        if isequal(decorations(k).Axes, ax)
            delete(decorations(k));
        end
    end

    cla(ax, 'reset');
end
