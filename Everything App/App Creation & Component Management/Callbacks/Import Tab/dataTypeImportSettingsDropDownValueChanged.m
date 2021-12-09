function []=dataTypeImportSettingsDropDownValueChanged(src)

%% PURPOSE: OPEN/CREATE NEW DATA TYPE-SPECIFIC IMPORTSETTINGS TO SPECIFY EACH DATA TYPE'S METADATA.

fig=ancestor(src,'figure','toplevel');

% 1. Get the value of the drop down
dataType=src.Value;

if isempty(dataType)
    return; % Do nothing if it is empty
end

% 2. Check if there is already an importSettings file of that data type in the project's import folder.
codePath=getappdata(fig,'codePath');
if isempty(codePath)
    beep;
    warning(['Missing code path']);
    return;
end
projectName=getappdata(fig,'projectName');
importFolder=[codePath 'Import_' projectName codePath(end)];
fileName=[importFolder 'importSettings_' dataType '_' projectName '.m'];

existingDataTypes=src.Items;
if exist(fileName,'file')~=2
    % 3. If there isn't, make one.
    A{1}=['function []=importSettings_' dataType '_' projectName '()'];
    A{2}='';
    A{3}=['%% PURPOSE: SPECIFY THE METADATA FOR ' dataType ' DATA'];
    
    fid=fopen(fileName,'w');
    if isequal(fid,-1)
        warning('Incorrect code path');
        return;
    end
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end}); % Because there's only one line. If multiple use '%s\n' for lines prior to end.
    fclose(fid);
    if isequal(existingDataTypes{1},'')
        src.Items={dataType};
    else
        src.Items=[existingDataTypes dataType];
    end
    
    charItems='';
    for kk=1:length(src.Items)
        if kk>1
            charItems=[charItems ', ' src.Items{kk}];       
        elseif k==1
            charItems=src.Items{kk};
        end
    end
    
    % Save the data type to the project names file
    text=readAllProjects(getappdata(fig,'everythingPath'));
    text=addProjInfoToFile(text,projectName,'Data Types:',charItems);
    
    fid=fopen(getappdata(fig,'allProjectsTxtPath'),'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);
end

% 4. Open the file
edit(fileName);