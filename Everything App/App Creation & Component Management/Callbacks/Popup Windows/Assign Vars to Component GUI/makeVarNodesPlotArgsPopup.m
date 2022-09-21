function []=makeVarNodesPlotArgsPopup(fig,sortIdx,VariableNamesList,structComp)

handles=getappdata(fig,'handles');
delete(handles.varsListbox.Children);

if isempty(sortIdx)
    beep;
    disp('No results found');
    return;
end

for i=1:length(sortIdx)
    varNode=uitreenode(handles.varsListbox,'Text',VariableNamesList.GUINames{sortIdx(i)});
    splitNames=VariableNamesList.SplitNames{sortIdx(i)};
    splitCodes=VariableNamesList.SplitCodes{sortIdx(i)};
    for j=1:length(splitCodes)
        splitName=splitNames{j};
        splitCode=splitCodes{j};
        a=uitreenode(varNode,'Text',[splitName ' (' splitCode ')']);
        if i==1 && j==1
            expand(varNode);
            handles.varsListbox.SelectedNodes=a;
        end
    end
end

delete(handles.selVarsListbox.Children);

for i=1:length(structComp.Names)

    varNode=uitreenode(handles.selVarsListbox,'Text',structComp.Names{i});

    if i==1
        handles.selVarsListbox.SelectedNodes=varNode;
        selVarsListboxValueChanged(fig);
    end

end

if isfield(structComp,'HardCodedValue')
    if ischar(structComp.HardCodedValue)
        handles.hardCodedTextArea.Value=structComp.HardCodedValue;
    elseif isa(structComp.HardCodedValue,'double')
        if length(structComp.HardCodedValue)==1
            handles.hardCodedTextArea.Value=num2str(structComp.HardCodedValue);
        else
            text='[';
            for i=1:length(structComp.HardCodedValue)
                text=[text num2str(structComp.HardCodedValue(i)) ' '];
            end
            text=[text(1:end-1) ']'];
            handles.hardCodedTextArea.Value=text;
        end
    end
end