function []=dataTypeImportMethodFieldValueChanged(src)

%% PURPOSE: STORE THE METHOD NUMBER & LETTER FOR ONE DATA TYPE'S IMPORT

fig=ancestor(src,'figure','toplevel');
hText=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');
methodNum=upper(hText.Value); % Always capital letters

hDataTypesDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
currType=hDataTypesDropDown.Value;
alphaNumericIdx=isstrprop(currType,'alpha') | isstrprop(currType,'digit');
dataType=lower(currType(alphaNumericIdx));
% setappdata(fig,[currType 'ImportNum'],methodNum);

% Check that there are only letters and numbers here, no spaces or special characters
try
    assert(isequal(length(hText.Value),sum(isstrprop(hText.Value,'alpha'))+sum(isstrprop(hText.Value,'digit'))));
catch
    warning('Only numbers + letters allowed in the data type import method field!');
    return;
end

try
    assert(isequal(length(methodNum),sum(isstrprop(methodNum,'alpha'))+sum(isstrprop(methodNum,'digit'))));    
catch
    warning('Must have first one number followed by one letter');
    return;
end
hText.Value=methodNum;

if isequal(currType,'No Data Types to Import')
    warning('Add a Data Type First!');
    return;
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
prevExist=0; % Initialize that the data type was not previously existing.
if isfield(projectNamesInfo,'DataTypes')
    % Need to check whether the current data type has been entered before.
    % If so, just modify method number & letter
    itemsOrig=strsplit(projectNamesInfo.DataTypes,', ');
    lineNum=lineNums.DataTypes;
    % Check all existing data types to see if they just 'contain' the
    % current data type, or if they exactly match it.
            
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
        newText=[newText currType ' ' methodNum suffix];
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
        [text]=addProjInfoToFile(text,projectName,prefix,[', ' currType ' ' methodNum],1);        
    end
else
    [text]=addProjInfoToFile(text,projectName,prefix,[currType ' ' methodNum],0);
end

% Save the text file
fid=fopen(getappdata(fig,'allProjectsTxtPath'),'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);

if prevExist==0
    dataTypeImportMethodFieldValueChanged(hText); % Lazy way of having a new data type moved to the front.
end

% Change the importMetadata and importFcn labels based on the file
% existence
if prevExist==1
    hImportMetadataButton=findobj(fig,'Type','uibutton','Tag','OpenImportMetadataButton');
    hImportFcnButton=findobj(fig,'Type','uibutton','Tag','OpenImportFcnButton');
    
    if ismac==1
        slash='/';
    elseif ispc==1
        slash='\';
    end    
    
    if exist([getappdata(fig,'codePath') 'Import_' projectName slash dataType 'ImportMetadata' methodNum(isletter(methodNum)) '_' projectName '.m'],'file')==2
        prefix='Open';
    else
        prefix='Create';
    end
    hImportMetadataButton.Text=[prefix ' importMetadata'];
    
    if exist([getappdata(fig,'codePath') 'Import_' projectName slash dataType 'Import' methodNum(~isletter(methodNum)) '_' projectName '.m'],'file')==2
        prefix='Open';
    else
        prefix='Create';
    end
    hImportFcnButton.Text=[prefix ' Import Fcn'];
    
    
end