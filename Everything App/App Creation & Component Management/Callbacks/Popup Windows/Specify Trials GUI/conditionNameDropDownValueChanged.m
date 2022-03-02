function []=conditionNameDropDownValueChanged(src)

%% PURPOSE: FILL IN ALL OF THE LOGSHEET & STRUCT CRITERIA FOR THE CURRENT CONDITION WITHIN THE CURRENT SPECIFY TRIALS VERSION
% Inputs:
% src: The condition name drop down (handle)
% type: Include or Exclude tab (char)
% condNum: condition number (double)

value=src.Value;
condNum=find(ismember(src.Items,value)==1,1);
fig=ancestor(src,'figure','toplevel');
pguiFig=evalin('base','gui;');
inclStruct=getappdata(fig,'inclStruct');
handles=getappdata(fig,'handles');

type=handles.Top.includeExcludeTabGroup.SelectedTab.Title;

% logsheetHandles=getappdata(fig,'logsheetEntryHandles');
% structHandles=getappdata(fig,'structEntryHandles');

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
            currSubTab=handles.(type).LogTab;
            set(currSubTab,'SizeChangedFcn',@(currSubTab,event) logsheetTabResize(currSubTab));
        case 2
            type2='Structure';
            currSubTab=handles.(type).StructTab;
    end           

    if isequal(type,'Include')
        pref='incl';
    elseif isequal(type,'Exclude')
        pref='excl';
    end

    % Delete items
    switch i
        case 1            
            if ~isempty(getappdata(fig,[pref 'LogsheetEntryHandles']))
                currHandles=getappdata(fig,[pref 'LogsheetEntryHandles']);
            else
                currHandles='';
            end
        case 2
            if ~isempty(getappdata(fig,[pref 'StructEntryHandles']))
                currHandles=getappdata(fig,[pref 'StructEntryHandles']);
            else
                currHandles='';
            end
    end

    if isstruct(currHandles)
        for j=1:length(currHandles.ColName)
            delete(currHandles.Labels{j});
            delete(currHandles.DropDown{j});
            delete(currHandles.TextField{j});

            currSubTab.UserData=rmfield(currSubTab.UserData,['Labels' num2str(j)]);
            currSubTab.UserData=rmfield(currSubTab.UserData,['DropDown' num2str(j)]);
            currSubTab.UserData=rmfield(currSubTab.UserData,['TextField' num2str(j)]);
        end
    end

    if ~isstruct(inclStruct)
        return;
    end

    if ~isfield(inclStruct,type)
        continue;
    end

    if ~isfield(inclStruct.(type).Condition,type2) || (isfield(inclStruct.(type).Condition,type2) && isempty(inclStruct.(type).Condition(condNum).(type2)))
        continue; % The logsheet or structure criteria does not exist for this condition.
    end

    currType2Struct=inclStruct.(type).Condition(condNum).(type2);

    % Re-populate items
    if i==1 % Logsheet
        for j=1:numCols
            entryHandles.ColName{j}=headerRow{j};
            currLabel=uilabel(currSubTab,'Text',headerRow{j},'Tag',['Labels' num2str(j)]);
            entryHandles.Labels{j}=currLabel;
            currLogDropDown=uidropdown(currSubTab,'Items',logicOptions,'Value','ignore','Tag',['DropDown' num2str(j)],'ValueChangedFcn',@(currLogDropDown,event) logicDropDownValueChanged(currLogDropDown));
            entryHandles.DropDown{j}=currLogDropDown;
            currLogEditField=uieditfield(currSubTab,'text','Value','','Tag',['TextField' num2str(j)],'ValueChangedFcn',@(currLogEditField, event) logsheetEditFieldValueChanged(currLogEditField));
            entryHandles.TextField{j}=currLogEditField;

            currSubTab.UserData.(['Labels' num2str(j)])=entryHandles.Labels{j};
            currSubTab.UserData.(['DropDown' num2str(j)])=currLogDropDown;
            currSubTab.UserData.(['TextField' num2str(j)])=currLogEditField;

        end

        logsheetTabResize(currSubTab); % Position the components.

    end

    switch i
        case 1
            setappdata(fig,[pref 'LogsheetEntryHandles'],entryHandles);
        case 2
            setappdata(fig,[pref 'StructEntryHandles'],entryHandles);
    end

    for j=1:length(currType2Struct)
        currName=currType2Struct(j).Name;
        currValue=currType2Struct(j).Value;
        currLogic=currType2Struct(j).Logic; % is, is not, contains, does not contain, is empty, is not empty, ignore

        if ~iscell(currName)
            currName={currName};
        end

        if ~iscell(currValue)
            currValue={currValue};
        end

        if isequal(currLogic,'ignore')
            continue;
        end

        for k=1:length(entryHandles.ColName)
            if isequal(currName{1},entryHandles.ColName{k})
                entryHandles.DropDown{k}.Value=currLogic;
                if ~iscell(currType2Struct(j).Value)
                    newValue='';
                else
                    newValue='{';
                end
                if size(currValue,1)>=size(currValue,2) % AND logic
                    sym='; ';
                else
                    sym=', ';
                end
                for l=1:length(currValue)

                    if ischar(currValue{l})
                        modValue=['''' currValue{l} ''''];
                    else
                        modValue=currValue{l};
                    end

                    if l==1
                        newValue=[newValue modValue];
                    else
                        newValue=[newValue sym modValue];
                    end
                end
                if iscell(currType2Struct(j).Value)
                    newValue=[newValue '}'];
                end
                entryHandles.TextField{k}.Value=newValue;
            end
        end

    end

end