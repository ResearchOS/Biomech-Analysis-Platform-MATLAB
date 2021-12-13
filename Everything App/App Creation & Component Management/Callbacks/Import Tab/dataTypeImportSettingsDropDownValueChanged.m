function []=dataTypeImportSettingsDropDownValueChanged(src)

%% PURPOSE: UPDATE IN THE GUI THE METHOD NUMBER & LETTER ASSOCIATED WITH EACH DATA TYPE

fig=ancestor(src,'figure','toplevel');

% 1. Get the value of the drop down
dataType=src.Value;

% 2. Read from the allProjects txt file the method number & letter currently
% associated with that data type
text=readAllProjects(getappdata(fig,'everythingPath'));
projectName=getappdata(fig,'projectName');
[projectNamesInfo,lineNums]=isolateProjectNamesInfo(text,projectName);
lineNum=lineNums.DataTypes;
dataTypeEndIdx=strfind(text{lineNum},dataType)+length(dataType)-1;
commaIdx=strfind(text{lineNum}(dataTypeEndIdx:end),', ')+dataTypeEndIdx-1;
if isempty(commaIdx)
    method=text{lineNum}(dataTypeEndIdx+1:end);
else
    method=text{lineNum}(dataTypeEndIdx+1:commaIdx-1); % Number & letter
end

% 3. Set the dataTypeImportMethodField to be that number & letter
hText=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');
hText.Value=method;

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% Change the button prefix to be either 'Create' or 'Open'
% importMetadata
hButton=findobj(fig,'Type','uibutton','Tag','OpenImportMetadataButton');
if exist([getappdata(fig,'codepath') 'Import_' projectName slash dataType 'ImportMetadata' method(isletter(method)) '_' projectName '.m'],'file')==2
    prefix='Open';
else
    prefix='Create';
end
hButton.Text=[prefix ' importMetadata'];

% Import Fcn
hButton=findobj(fig,'Type','uibutton','Tag','OpenImportFcnButton');
if exist([getappdata(fig,'codePath') 'Import_' projectName slash dataType 'Import' method(~isletter(method)) '_' projectName '.m'],'file')==2
    prefix='Open';
else
    prefix='Create';
end
hButton.Text=[prefix ' Import Fcn'];