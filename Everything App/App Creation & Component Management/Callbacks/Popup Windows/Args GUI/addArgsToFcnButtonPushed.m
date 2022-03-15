function []=addArgsToFcnButtonPushed(src,event)

%% PURPOSE: ADD SELECTED ARGS IN ALL LIST TO CURRENT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

fcnName=getappdata(fig,'fcnName');
guiTab=getappdata(fig,'guiTab');
groupName=getappdata(fig,'groupName');

allListBox=handles.allArgsListBox;
fcnListBox=handles.fcnListBox;

% 1. Get the list of currently selected args in the 'All' box.
allArgsSelected=allListBox.Value;
fcnArgsItems=fcnListBox.Items;

% 2. Check if there are duplicate(s) in the current function box. Do not proceed if there are duplicates.
if any(ismember(allArgsSelected,fcnArgsItems))
    duplArgs=allArgsSelected(ismember(allArgsSelected,fcnArgsItems));
    duplArgsStr='';
    for i=1:length(duplArgs)
        duplArgsStr=[duplArgsStr ' ' duplArgs{i}];
    end
    warning(['No args added to function. Duplicated args: ' duplArgsStr]);
    return;
end

% 4. In the text file, copy the arg names from the 'Unassigned' group & function to the current group and function.
nameInCode='0 , 1 '; % Indicates that it is not synced by default (because 0 is in front).

text=readAllArgsTextFile(getappdata(fig,'everythingPath'),getappdata(fig,'projectName'),guiTab);
[argNames,~,argsDescs]=getAllArgNames(text,getappdata(fig,'projectName'),guiTab,'Unassigned',['Unassigned_' guiTab '1A']);

for i=1:length(allArgsSelected)

    argName=allArgsSelected{i};
    idx=ismember(argNames,argName);
    description=argsDescs(idx);
    assert(length(description)==1);
    description=description{1};
    writeAllArgsTextFile(getappdata(fig,'currProjectArgsTxtPath'),guiTab,groupName,fcnName,argName,getappdata(fig,'projectName'),nameInCode,description);

end

% 5. Add the arg names to the list box
if isequal(fcnListBox.Items,{'No Args'})
    fcnListBox.Items={};
end

fcnListBox.Items=sort(unique([fcnListBox.Items allArgsSelected]));
fcnListBox.Value=allArgsSelected{1};

% Update the argsDesc, nameInCode, and argNames vars

argNames=getappdata(fig,'argNames');
argsDesc=getappdata(fig,'argsDesc');
argsNameInCode=getappdata(fig,'argsNameInCode');

if ~iscell(argName)
    argName={argName};
end

[argNames,k]=sort([argNames argName]);
argsDesc=[argsDesc {description}];
argsDesc=argsDesc(k);
argsNameInCode=[argsNameInCode {nameInCode}];
argsNameInCode=argsNameInCode(k);

setappdata(fig,'argNames',argNames);
setappdata(fig,'argsDesc',argsDesc);
setappdata(fig,'argsNameInCode',argsNameInCode);

fcnListBoxValueChanged(fig);