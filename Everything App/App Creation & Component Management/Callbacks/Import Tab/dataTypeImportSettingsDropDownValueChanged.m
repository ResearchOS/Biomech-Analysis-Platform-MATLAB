function []=dataTypeImportSettingsDropDownValueChanged(src)

%% PURPOSE: UPDATE IN THE GUI THE METHOD NUMBER & LETTER ASSOCIATED WITH EACH DATA TYPE

fig=ancestor(src,'figure','toplevel');

if isempty(getappdata(fig,'codePath'))
    beep;
    warning('Need to enter the code path!');
    return;
end

% 1. Get the value of the drop down
currType=src.Value;
alphaNumericIdx=isstrprop(currType,'alpha') | isstrprop(currType,'digit');
dataType=currType(alphaNumericIdx);

hText=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');

% 2. Read from the allProjects txt file the method number & letter currently
% associated with that data type
text=readAllProjects(getappdata(fig,'everythingPath')); % Read the text file in
projectName=getappdata(fig,'projectName'); % Get the project name
[projectNamesInfo,lineNums]=isolateProjectNamesInfo(text,projectName); % Read the info associated with that project.

if ~isfield(projectNamesInfo,'DataTypes')
    warning('Issue with data types in text file');
    return;
end
prefix='Data Types:';
itemsOrig=strsplit(projectNamesInfo.DataTypes,', ');
lineNum=lineNums.DataTypes;
% Check all existing data types to see if they just 'contain' the
% current data type, or if they exactly match it.

prevExist=0; % Initialize that the data type was not previously existing.
for i=1:length(itemsOrig)
    currItem=strsplit(itemsOrig{i},' ');
    currItemType='';
    for j=1:length(currItem)-1
        if j>=2
            mid=' ';
        else
            mid='';
        end
        currItemType=[currItemType mid currItem{j}];
    end
    if isempty(currItemType) && length(currItem)==2
        currItemType=currItem{1};
    end
    if isequal(currItemType,currType)
        method=currItem{end}; % Always capital letters
        hText.Value=method;
        prevExist=1; % Exact match
        itemNum=i;
        break; % Because that data type (and method number/letter) can only be present once in the list.
    end
end

% Reconstitute the line of text, putting the current data type first.
if prevExist==1
    newText=[prefix ' '];
    if length(itemsOrig)>1
        suffix=', ';
    else
        suffix='';
    end
    newText=[newText currType ' ' method suffix];
    itemsNew=itemsOrig(~ismember(itemsOrig,itemsOrig{itemNum}));
    for i=1:length(itemsNew)
        if i==length(itemsNew) % End of line
            suffix='';
        else
            suffix=', ';
        end
        newText=[newText itemsNew{i} suffix];
    end
    text{lineNum}=newText;
else
    [text]=addProjInfoToFile(text,projectName,prefix,[', ' currType ' ' method],1);
end

% Save the text file
fid=fopen(getappdata(fig,'allProjectsTxtPath'),'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);

%% Change the data type-specific column header name
[projectNamesInfo,lineNums]=isolateProjectNamesInfo(text,projectName); % Read the info associated with that project.
fldNames=fieldnames(projectNamesInfo);
foundType=0; % Indicates that the data type was not found and the trial ID col header was not set.
hText=findobj(fig,'Type','uieditfield','Tag','DataTypeTrialIDColumnHeaderField');
for i=1:length(fldNames)
    currField=fldNames{i};
    if isequal(currField,['TrialIDColHeader' dataType])        
        hText.Value=projectNamesInfo.(currField);
        foundType=1; % Indicates that the data type was found and the trial ID col header properly set.
        break;
    end
end
if foundType==0
    hText.Value='Set Trial ID Col Header';
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% Change the button prefix to be either 'Create' or 'Open'
% importMetadata
hButton=findobj(fig,'Type','uibutton','Tag','OpenImportMetadataButton');
if exist([getappdata(fig,'codePath') 'Import_' projectName slash dataType 'ImportMetadata' method(isletter(method)) '_' projectName '.m'],'file')==2
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