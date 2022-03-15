function []=deleteFcnArgsVersionButtonPushed(src,event)

%% PURPOSE: REMOVE THE CURRENT ARGS VERSION FROM THE CURRENT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% currDrop=handles.nameInCodeEditField.Value;

currVals=handles.fcnListBox.Value;

argsNameInCode=getappdata(fig,'argsNameInCode');
argsDesc=getappdata(fig,'argsDesc');
argNames=getappdata(fig,'argNames');

fcnName=getappdata(fig,'fcnName');
groupName=getappdata(fig,'groupName');
guiTab=getappdata(fig,'guiTab');

projectName=getappdata(fig,'projectName');

dropDownVals=handles.fcnArgsVersionDropDown.Items; % Should be in alphabetical order

currDropDownVal=handles.fcnArgsVersionDropDown.Value; % Get the last letter
% newLastVal=char(double(prevLastVal-1)); % Decrement to the next letter

% incrIdx=[];
% if isequal(lastVal,repmat('Z',size(lastVal)))
%     lastVal=repmat('A',1,length(lastVal)+1); % Add another element to the letter
% else % No element added, just incremented.
%     for i=length(lastVal):1
%         if isequal(lastVal(i),'Z')
%             incrIdx=[incrIdx i-1];
%             lastVal(i)=char(double(lastVal(i)+1)); % Increment to the next letter
%         end
%     end
% end

fcnNameOnlyIdx=strfind(fcnName,['_' guiTab]);
fcnNameOnly=fcnName(1:fcnNameOnlyIdx-1);
methodID=fcnName(fcnNameOnlyIdx+length(['_' guiTab]):end);
methodNum=methodID(isstrprop(methodID,'digit'));

fcnNameToDelete=[fcnNameOnly '_' guiTab methodNum currDropDownVal];

if length(handles.fcnArgsVersionDropDown.Items)==1
    warning(['Cannot delete this version as it is the only one for this function!']);
    return;
end


input=inputdlg(['Enter the fcn name to confirm deletion: ' fcnNameToDelete]);
if isempty(input) || isempty(input{1})
    return;
end

if ~isequal(input{1},fcnNameToDelete)
    disp(['Nothing Deleted! Input ' input{1} ' Did Not Match Fcn Name: ' fcnNameToDelete]);
    return;
end

% Copy the previous last value's args in the text file, and display it in the GUI.
if ~deleteFcnInAllArgsTextFile(getappdata(fig,'currProjectArgsTxtPath'),guiTab,groupName,fcnName,projectName)
    return;
end

% Set the new letter to be the current value
handles.fcnArgsVersionDropDown.Items=sort(unique(handles.fcnArgsVersionDropDown.Items(~ismember(handles.fcnArgsVersionDropDown.Items,currDropDownVal))));
handles.fcnArgsVersionDropDown.Value=handles.fcnArgsVersionDropDown.Items(end);

fcnName=[fcnNameOnly '_' guiTab methodNum handles.fcnArgsVersionDropDown.Items{end}];
setappdata(fig,'fcnName',fcnName);

% Propagate changes
fcnArgsVersionDropDownValueChanged(fig);

disp(['Deleted ' fcnName]);
