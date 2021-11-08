function []=dataTypeImportSettingsDropDownValueChanged(src)

%% PURPOSE: OPEN/CREATE NEW DATA TYPE-SPECIFIC IMPORTSETTINGS TO SPECIFY EACH DATA TYPE'S METADATA.

fig=ancestor(src,'figure','toplevel');

% 1. Get the value of the drop down
dataType=src.Value;

% 2. Check if there is already an importSettings file of that data type in the project's import folder.
codePath=getappdata(fig,'codePath');
projectName=getappdata(fig,'projectName');
importFolder=[codePath 'Import_' projectName codePath(end)];
fileName=[importFolder 'importSettings_' dataType '_' projectName '.m'];
if exist(fileName,'file')~=2
    % 3. If there isn't, make one.
    A{1}=['function []=importSettings_' dataType '_' projectName '()'];
    A{2}='';
    A{3}=['%% PURPOSE: SPECIFY THE METADATA FOR ' dataType ' DATA'];
    
    fid=fopen(fileName,'w');
    if isequal(fid,-1)
        warning('Check the code path...');
        return;
    end
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end}); % Because there's only one line. If multiple use '%s\n' for lines prior to end.
    fclose(fid);
end

% 4. If there is, open it.
edit([importFolder 'importSettings_' dataType '_' projectName]);