function [name]=promptName(prompt,default)

%% PURPOSE: PROMPT THE USER WITH INPUTDLG FOR A NEW NAME.
% NAMES MUST BE VALID MATLAB VARIABLE NAMES.

isValid=false;

if exist('default','var')~=1
    default='';
end

if ~iscell(default)
    default={default};
end

while ~isValid

    name=inputdlg(prompt,'',1,default);    

    name=strrep(name,' ','_');

    if isempty(name) || isempty(name{1})
        return; % Pressed Cancel, or did not enter anything.
    end

    name=name{1};

    if ~isvarname(name)
        disp('Name must be valid MATLAB variable name, but spaces are OK.')
        continue;
    end

    isValid=true;

end