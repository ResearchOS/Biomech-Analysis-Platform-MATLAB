function [bool]=removeArgsFromFcnButtonPushed(src,event)

%% PURPOSE: REMOVE SELECTED ARGS FROM THE CURRENT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

fcnName=getappdata(fig,'fcnName');
guiTab=getappdata(fig,'guiTab');
groupName=getappdata(fig,'groupName');

% allListBox=handles.allArgsListBox;
fcnListBox=handles.fcnListBox;

% 1. Get the list of currently selected args in the 'All' box.
fcnArgsSelected=fcnListBox.Value;
fcnArgsItems=fcnListBox.Items;
    

if length(fcnArgsItems)==1
    if ~isequal(fcnListBox.Items{1},'No Args')
        fcnListBox.Items={'No Args'};
    else
        warning('Already no arguments in function!')
        return;
    end
else
    idx=~ismember(fcnListBox.Items,fcnArgsSelected); % Remaining entries.
    fcnListBox.Items=fcnListBox.Items(idx);
    fcnListBox.Items=fcnListBox.Items;    
end

fcnListBox.Value=fcnListBox.Items{1};

for i=1:length(fcnArgsSelected)
    argName=fcnArgsSelected{i};
    if ~deleteArgFromAllArgsTextFile(getappdata(fig,'currProjectArgsTxtPath'),guiTab,groupName,fcnName,argName,getappdata(fig,'projectName'))
        disp(['Removed ' argName ' From ' fcnName]);
        return;
    end
end

if length(fcnArgsItems)>1
    argNames=getappdata(fig,'argNames');
    argsDesc=getappdata(fig,'argsDesc');
    argsNameInCode=getappdata(fig,'argsNameInCode');

    argNames=argNames(idx);
    argsDesc=argsDesc(idx);
    argsNameInCode=argsNameInCode(idx);

    setappdata(fig,'argNames',argNames);
    setappdata(fig,'argsDesc',argsDesc);
    setappdata(fig,'argsNameInCode',argsNameInCode);
else
    setappdata(fig,'argNames',{});
    setappdata(fig,'argsDesc',{});
    setappdata(fig,'argsNameInCode',{});
end

fcnListBoxValueChanged(fig);