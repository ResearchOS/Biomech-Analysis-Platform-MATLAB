function []=addFcnArgsVersionButtonPushed(src,event)

%% PURPOSE: ADD A NEW ARGS VERSION TO THE CURRENT FUNCTION. COPIES FROM THE CURRENT VERSION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% nameInCodeVal=handles.nameInCodeEditField.Value;

currVals=handles.fcnListBox.Value;

argsNameInCode=getappdata(fig,'argsNameInCode');
argsDesc=getappdata(fig,'argsDesc');
argNames=getappdata(fig,'argNames');

fcnName=getappdata(fig,'fcnName');
groupName=getappdata(fig,'groupName');
guiTab=getappdata(fig,'guiTab');

projectName=getappdata(fig,'projectName');

dropDownVals=handles.fcnArgsVersionDropDown.Items; % Should be in alphabetical order

prevLastVal=dropDownVals{end}; % Get the last letter
newLastVal=char(double(prevLastVal+1)); % Increment to the next letter

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

fcnNameNew=[fcnNameOnly '_' guiTab methodNum newLastVal];

% Copy the previous last value's args in the text file, and display it in the GUI.
if ~copyFcnInAllArgsTextFile(getappdata(fig,'currProjectArgsTxtPath'),guiTab,groupName,fcnNameNew,fcnName,projectName)
    return;
end

% Set the new letter to be the current value
handles.fcnArgsVersionDropDown.Items=sort(unique([handles.fcnArgsVersionDropDown.Items {newLastVal}]));
handles.fcnArgsVersionDropDown.Value=newLastVal;

setappdata(fig,'fcnName',fcnNameNew);

% Propagate changes
fcnArgsVersionDropDownValueChanged(fig);

disp(['Added ' fcnNameNew]);
