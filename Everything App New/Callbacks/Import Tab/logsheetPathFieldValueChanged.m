function []=logsheetPathFieldValueChanged(src,event)

%% PURPOSE: STORE THE LOGSHEET PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Import.logsheetPathField.Value;

if isempty(path)
    return;
end

slash=filesep;

logsheetNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(logsheetNode)
    return;
end

uuid = logsheetNode.NodeData.UUID;

struct=loadJSON(uuid);

if exist(path,'file')~=2
    disp('Specified path is not a file or does not exist!');
    handles.Import.numHeaderRowsField.Value=-1;
    handles.Import.subjectCodenameDropDown.Items={''};
    handles.Import.targetTrialIDDropDown.Items={''};
    return;
end

computerID=getComputerID();

struct.LogsheetPath.(computerID)=path;

[logsheetFolder,name,ext]=fileparts(path);
logsheetPathMAT=[logsheetFolder slash name '.mat'];

if contains(ext,'xls')
    [~,~,logVar]=xlsread(path,1);
end

headers=logVar(1,:)';

isValidName=false(size(headers));
for i=1:length(headers)
    isValidName(i)=isvarname(headers{i});
end

if any(~isValidName)
    disp('Header names must be valid variable names!');
    disp(headers(~isValidName));
    handles.Import.numHeaderRowsField.Value=-1;
    handles.Import.subjectCodenameDropDown.Items={''};
    handles.Import.targetTrialIDDropDown.Items={''};
    return;
end

if isempty(struct.Headers)
    struct.Headers=headers;
    struct.Level=repmat({''},length(headers),1);
    struct.Type=repmat({''},length(headers),1);
    struct.Variables=repmat({''},length(headers),1);
end

save(logsheetPathMAT,'logVar');

writeJSON(getJSONPath(struct),struct);

headersAll=[{''}; headers];

handles.Import.subjectCodenameDropDown.Items=headersAll;
handles.Import.targetTrialIDDropDown.Items=headersAll;

%% Fill the headers UI Tree
fillHeadersUITree(fig,headers);