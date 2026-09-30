function figure_title(ax, name, caption)
%FIGURE_TITLE Title an axes with a bold name and a smaller caption below it.
%
%   FIGURE_TITLE(ax, name, caption) writes name as the title and caption as
%   the subtitle, in a smaller grey font. caption may be a char row or a cell
%   array of lines. Either may be '' to show nothing.
%
%   Every plot in this library uses it, so that each figure carries the same
%   two-part identification: WHAT the object is called (by default the
%   caller's variable name) and WHAT it contains. Purely presentational, and
%   both parts are overridable through the 'Title' and 'Subtitle' options.
%
%   See also PICK_LABEL, PLOT_GRAPH, PLOT_OPINIONS.

    if ~is_blank(name)
        title(ax, name, 'Interpreter', 'none', 'FontWeight', 'bold');
    end

    if ~is_blank(caption)
        subtitle(ax, caption, 'Interpreter', 'none', ...
            'FontSize', 8, 'FontWeight', 'normal', 'Color', [0.30 0.30 0.30]);
    end
end

% -------------------------------------------------------------------------
function tf = is_blank(label)
%IS_BLANK True for '' or {} or a cell array of empty strings.
    if isempty(label)
        tf = true;
    elseif iscell(label)
        tf = all(cellfun(@isempty, label));
    else
        tf = false;
    end
end
