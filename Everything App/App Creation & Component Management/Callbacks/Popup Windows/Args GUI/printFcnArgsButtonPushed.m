function []=printFcnArgsButtonPushed(src,event)

%% PURPOSE: PRINT THE CURRENT SELECTION OF FUNCTION ARGS TO THE COMMAND WINDOW FOR COPYING AND PASTING INTO CODE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
fcnName=getappdata(fig,'fcnName');

currVals=sort(handles.fcnListBox.Value);

allItems=handles.fcnListBox.Items;

[text]=readAllArgsTextFile(getappdata(fig,'everythingPath'),getappdata(fig,'projectName'),getappdata(fig,'guiTab'));
[~,argsNamesInCode]=getAllArgNames(text,getappdata(fig,'projectName'),getappdata(fig,'guiTab'),getappdata(fig,'groupName'),fcnName);

inputStr='{';
outputStr='';
argsNamesInCode=argsNamesInCode(ismember(allItems,currVals));
for i=1:length(currVals)

    currArgNameInCode=argsNamesInCode{i};
    currArgNameSplit=strsplit(currArgNameInCode,',');
    beforeCommaSplit=strsplit(currArgNameSplit{1},' ');
    %     afterCommaSplit=strsplit(currArgNameSplit{2},' ');

    if isequal(beforeCommaSplit{1},'0')
        inputStr=[inputStr '''' beforeCommaSplit{2} '''' ','];
        outputStr=[outputStr beforeCommaSplit{2} ','];
    end

end
inputStr=[inputStr(1:end-1) '}']; % Remove the final comma
outputStr=outputStr(1:end-1);

disp('Inputs: ');
disp(inputStr);
disp(char(13));
disp('Outputs:')
disp(outputStr);