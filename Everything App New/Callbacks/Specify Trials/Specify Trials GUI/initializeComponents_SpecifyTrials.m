function [handles]=initializeComponents_SpecifyTrials(src,event)

%% PURPOSE: CREATE ALL OF THE COMPONENTS FOR THE SPECIFY TRIALS GUI

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

defaultPos=get(0,'defaultfigureposition'); % Get the default figure position
set(fig,'Position',defaultPos);
figSize=get(fig,'Position'); % Get the figure's position.
figSize=figSize(3:4); 

%% Create tab group with Logsheet & Variables tabs
tabGroup1=uitabgroup(fig,'Position',[0 0 figSize],'AutoResizeChildren','off');
fig.UserData=struct('TabGroup1',tabGroup1);
handles.Tabs.tabGroup1=tabGroup1;
logsheetTab=uitab(tabGroup1,'Title','Logsheet','AutoResizeChildren','off');
varsTab=uitab(tabGroup1,'Title','Variables','AutoResizeChildren','off');

handles.Logsheet.Tab=logsheetTab;
handles.Variables.Tab=varsTab;

setappdata(fig,'handles',handles);

logic={'ignore','greater than','less than','equals','does not equal','contains','does not contain'};

%% Initialize the logsheet tab.
% 1. All logsheet headers UI tree
handles.logsheetHeadersUITree=uitree(logsheetTab);

% 2. Assign logsheet header button
handles.assignLogsheetHeaderButton=uibutton(logsheetTab,'Text','->','ButtonPushedFcn',@(assignLogsheetHeaderButton,event) assignLogsheetHeaderButtonPushed(assignLogsheetHeaderButton));

% 3. Unassign logsheet header button
handles.unassignLogsheetHeaderButton=uibutton(logsheetTab,'Text','<-','ButtonPushedFcn',@(unassignLogsheetHeaderButton,event) unassignLogsheetHeaderButtonPushed(unassignLogsheetHeaderButton));

% 4. Logic dropdown
handles.logsheetLogicDropDown=uidropdown(logsheetTab,'Items',logic,'Value','ignore','ValueChangedFcn',@(logsheetLogicDropDown,event) logsheetLogicDropDownValueChanged(logsheetLogicDropDown));

% 5. Value edit field
handles.logsheetLogicValueEditField=uieditfield(logsheetTab,'Value','','ValueChangedFcn',@(logsheetLogicValueEditField,event) logsheetLogicValueEditFieldValueChanged(logsheetLogicValueEditField));

% 6. Selected logsheet headers UI tree
handles.selectedLogsheetHeadersUITree=uitree(logsheetTab,'SelectionChangedFcn',@(selectedLogsheetHeadersUITree,event) selectedLogsheetHeadersUITreeSelectionChanged(selectedLogsheetHeadersUITree));

%% Initialize the variables tab.
% 1. All variables UI tree
handles.variablesUITree=uitree(varsTab);

% 2. Assign variables button
handles.assignVariablesButton=uibutton(varsTab,'Text','->','ButtonPushedFcn',@(assignVariablesButton,event) assignVariablesButtonPushed(assignVariablesButton));

% 3. Unassign variables button
handles.unassignVariablesButton=uibutton(varsTab,'Text','<-','ButtonPushedFcn',@(unassignVariablesButton,event) unassignVariablesButtonPushed(unassignVariablesButton));

% 4. Logic dropdown
handles.variablesLogicDropDown=uidropdown(varsTab,'Items',logic,'Value','ignore');

% 5. Value edit field
handles.variablesLogicValueEditField=uieditfield(varsTab,'Value','');

% 6. Selected variables UI tree
handles.selectedVariablesUITree=uitree(varsTab);