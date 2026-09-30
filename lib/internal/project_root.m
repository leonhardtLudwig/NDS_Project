function root = project_root()
%PROJECT_ROOT Absolute path of the project root folder.
%
%   root = PROJECT_ROOT() returns the folder that contains SETUP_PATHS.M.
%   Use it to build robust paths to data and figure folders, e.g.
%
%       f = fullfile(project_root(), 'data', 'krackhardt_advice_LAS.txt');
%
%   This function works regardless of the current working directory.
%
%   See also SETUP_PATHS.

    thisFile = mfilename('fullpath');            % <root>/lib/internal/project_root
    root = fileparts(fileparts(fileparts(thisFile)));
end
