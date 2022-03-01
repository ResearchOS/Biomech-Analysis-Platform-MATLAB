function []=conditionNameDropDownValueChanged(src, type)

%% PURPOSE: FILL IN ALL OF THE LOGSHEET & STRUCT CRITERIA FOR THE CURRENT CONDITION WITHIN THE CURRENT SPECIFY TRIALS VERSION
% Inputs:
% src: The condition name drop down (handle)
% type: Include or Exclude tab (char)

value=src.Value;
fig=ancestor(src,'figure','toplevel');
pguiFig=evalin('base','gui;');
inclStruct=getappdata(fig,'inclStruct');

logsheetHandles=getappdata(fig,'logsheetEntryHandles');
structHandles=getappdata(fig,'structEntryHandles');

logVar=load(getappdata(pguiFig,'LogsheetMatPath'));
fldName=fieldnames(logVar);
assert(length(fldName)==1);
logVar=logVar.(fldName{1});
headerRow=logVar(1,:);
numCols=length(headerRow);
logicOptions={'is','is not','contains','does not contain','is empty','is not empty','ignore'};

for i=1:2 % Logsheet or structure

    switch i
        case 1
            type2='Logsheet';
            currSubTab=currTab.LogTab;
        case 2
            type2='Structure';
            currSubTab=currTab.StructTab;
    end

    if ~isfield(currStruct.Condition,type2) || (isfield(currStruct.Condition,type2) && isempty(currStruct.Condition(condNum).(type2)))
        continue; % The logsheet or structure criteria does not exist for this condition.
    end

    currType2Struct=currStruct.Condition(condNum).(type2);

    % Delete items
    switch i
        case 1
            if ~isempty(getappdata(fig,'logsheetEntryHandles'))
                currHandles=getappdata(fig,'logsheetEntryHandles');
            else
                currHandles='';
            end
        case 2
            if ~isempty(getappdata(fig,'structEntryHandles'))
                currHandles=getappdata(fig,'structEntryHandles');
            else
                currHandles='';
            end
    end

    for j=1:length(currHandles)
        delete(currHandles.Labels{j});
        delete(currHandles.DropDown{j});
        delete(currHandles.TextField{j});

        currSubTab.UserData=rmfield(currSubTab.UserData,['Labels' num2str(j)]);
        currSubTab.UserData=rmfield(currSubTab.UserData,['DropDown' num2str(j)]);
        currSubTab.UserData=rmfield(currSubTab.UserData,['TextField' num2str(j)]);
    end

    % Re-populate items
    if i==1 % Logsheet
        for j=1:numCols
            entryHandles.ColName{j}=headerRow{j};
            currLabel=uilabel(currSubTab,'Text',headerRow{j});
            entryHandles.Labels{j}=currLabel;
            currLogDropDown=uidropdown(currSubTab,'Items',logicOptions,'Value','ignore','ValueChangedFcn',@(currLogDropDown,event) logicDropDownValueChanged(currLogDropDown));
            entryHandles.DropDown{j}=currLogDropDown;
            currLogEditField=uieditfield(currSubTab,'text','Value','','ValueChangedFcn',@(currLogEditField, event) logsheetEditFieldValueChanged(currLogEditField));
            entryHandles.TextField{j}=currLogEditField;

            currSubTab.UserData.(['Labels' num2str(j)])=entryHandles.Labels{j};
            currSubTab.UserData.(['DropDown' num2str(j)])=currLogDropDown;
            currSubTab.UserData.(['TextField' num2str(j)])=currLogEditField;

        end

        logsheetTabResize(currSubTab); % Position the components.

    end

    switch i
        case 1
            setappdata(fig,'logsheetEntryHandles',entryHandles);
        case 2
            setappdata(fig,'structEntryHandles',entryHandles);
    end

    for j=1:length(currType2Struct)
        currName=currType2Struct.Name;
        currValue=currType2Struct.Value;
        currLogic=currType2Struct.Logic; % is, is not, contains, does not contain, is empty, is not empty, ignore

        if isequal(currLogic,'ignore')
            continue;
        end

        for k=1:length(entryHandles.ColName)
            if isequal(currName,entryHandles.ColName{k})
                entryHandles.DropDown{j}.Value=currLogic;
                entryHandles.TextField{j}.Value=currValue;
            end
        end

    end



end