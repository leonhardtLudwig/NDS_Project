function s = pick_label(given, automatic)
%PICK_LABEL Choose between a caller-supplied label and the automatic one.
%
%   s = PICK_LABEL(given, automatic) implements the convention used by every
%   'Title' and 'Subtitle' option in this library:
%
%       given = []          use the automatic text (the default)
%       given = 'my text'   use that text verbatim
%       given = ''          show nothing
%
%   The distinction between [] and '' is what makes the annotations
%   suppressible: both are empty, but only the numeric [] means "not
%   specified".
%
%   See also FIGURE_TITLE, PLOT_GRAPH.

    if isnumeric(given) && isempty(given)
        s = automatic;
    else
        s = given;
    end
end
