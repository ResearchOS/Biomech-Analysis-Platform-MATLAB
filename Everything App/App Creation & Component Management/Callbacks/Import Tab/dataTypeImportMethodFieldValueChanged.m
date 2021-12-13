function []=dataTypeImportMethodFieldValueChanged(src)

%% PURPOSE: STORE THE METHOD NUMBER & LETTER FOR ONE DATA TYPE'S IMPORT

fig=ancestor(src,'figure','toplevel');
hText=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');
methodNum=upper(hText.Value); % Always capital letters
hText.Value=methodNum;

hDataTypesDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
currType=hDataTypesDropDown.Value;
% setappdata(fig,[currType 'ImportNum'],methodNum);

% Check that there are only letters and numbers here, no spaces or special characters
try
    assert(isequal(length(hText.Value),sum(isstrprop(hText.Value,'alpha'))+sum(isstrprop(hText.Value,'digit'))));
catch
    warning('Only numbers + letters allowed in the data type import method field!');
end

%% Save this to file
% Format: 'Data Types: FP1A, MOCAP2B'

% Read the text file.
text=readAllProjects(getappdata(fig,'everythingPath'));
% If 'Data Types' already exists for this project, then append to it.
% Otherwise, create it.
projectName=getappdata(fig,'projectName');
[projectNamesInfo,lineNums]=isolateProjectNamesInfo(text,projectName);
prefix='Data Types:';
if isfield(projectNamesInfo,'DataTypes')
    % Need to check whether the current data type has been entered before.
    % If so, just modify method number & letter
    lineNum=lineNums.DataTypes;
    if contains(text{lineNum},currType) % This specific data type already exists.
        endDataTypeIdx=strfind(text{lineNum},currType)+length(currType)-1;
        % If endDataTypeCommaIdx is empty, it means this data type is the last
        % one in the line
        endDataTypeCommaIdx=strfind(text{lineNum}(endDataTypeIdx:end),', ')+endDataTypeIdx-1;
        newText=text{lineNum}(1:endDataTypeIdx); % Get the data type label again.
        if isempty(endDataTypeCommaIdx)
            newText(endDataTypeIdx+1:length(text{lineNum}))=methodNum;            
        else
            newText(endDataTypeIdx+1:endDataTypeCommaIdx-1)=methodNum;
            newText(endDataTypeCommaIdx:endDataTypeCommaIdx+length(text{lineNum}(endDataTypeCommaIdx:end))-1)=text{lineNum}(endDataTypeCommaIdx:end);
        end
        text{lineNum}=newText;
    else % This data type does not yet exist.
        [text]=addProjInfoToFile(text,projectName,prefix,[', ' currType methodNum],1);
    end
else
    [text]=addProjInfoToFile(text,projectName,prefix,[currType methodNum],0);
end

% Save the text file
fid=fopen(getappdata(fig,'allProjectsTxtPath'),'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);