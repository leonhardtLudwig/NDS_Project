function projectRoot = setup_paths()
%SETUP_PATHS Put the delivered library on the MATLAB path.
%
%   SETUP_PATHS adds this folder and the subfolders of lib/ to the path and,
%   with an output argument, returns the folder it lives in. The two live
%   scripts call it from their first cell, so running them is enough.

    projectRoot = fileparts(mfilename('fullpath'));
    folders = { ...
        projectRoot, ...
        fullfile(projectRoot, 'lib', 'internal'), ...
        fullfile(projectRoot, 'lib', 'matrices'), ...
        fullfile(projectRoot, 'lib', 'models'), ...
        fullfile(projectRoot, 'lib', 'analysis'), ...
        fullfile(projectRoot, 'lib', 'viz')};
    for k = 1:numel(folders)
        if ~isfolder(folders{k})
            error('NDS:setupPaths:missingFolder', ...
                'Expected project folder is missing: %s', folders{k});
        end
        addpath(folders{k});
    end
    if nargout == 0
        clear projectRoot;
    end
end
