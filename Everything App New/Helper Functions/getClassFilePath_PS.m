function [fullPath]=getClassFilePath_PS(name_PS, class, src)

%% PURPOSE: RETURN THE FULL FILE PATH FOR THE SPECIFIED PROJECT-SPECIFIC STRUCT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

projectPath=getProjectPath(fig);

classFolder=[projectPath slash 'Project_Settings' slash class];

fullPath=[classFolder slash class '_' name_PS '.json'];