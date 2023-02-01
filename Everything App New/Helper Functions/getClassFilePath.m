function [fullPath]=getClassFilePath(text,class)

%% PURPOSE: GET THE CLASS FULL FILE PATH FROM THE SELECTED NODE

if isempty(text)
    fullPath='';
    return;
end

% This allows this one function to do both project-independent and
% project-specific actions (should be cleaned up in the future.
if ischar(text)
    [name, id, psid]=deText(text);
    if ~isempty(psid)
        [fullPath]=getClassFilePath_PS(text, class);
        return;
    end
end

if ~ischar(text)
    parent=text.Parent;

    class=getClassFromUITree(parent);

    file=text.Text;
else
    file=text; % Node text specified directly
end

slash=filesep;

commonPath=getCommonPath();
classFolder=[commonPath slash class];
fullPath=[classFolder slash class '_' file '.json'];