function []=editPubTableSizeChangedFcn(src,event)

%% PURPOSE: CHANGE THE SIZE OF COMPONENTS WHEN THE FIGURE CHANGES SIZE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

size=fig.Position(3:4);
size=[size size];

if isempty(handles)
    return;
end

maxR=handles.numRowsEditField.Value;
maxC=handles.numColsEditField.Value;

handles.tablePanel.Position=[0.01 0.01 0.9667 0.86].*size;
handles.numRowsLabel.Position=[0.01 0.90 0.08 0.06].*size;
handles.numRowsEditField.Position=[0.1 0.9 0.15 0.06].*size;
handles.numColsLabel.Position=[0.4167    0.9000    0.1667    0.0600].*size;
handles.numColsEditField.Position=[0.5000    0.9000    0.1667    0.0600].*size;

if maxR>=3
    cellSize(2)=(size(2)*0.85)/3;
else
    cellSize(2)=(size(2)*0.85)/maxR;
end

if maxC>=3
    cellSize(1)=(size(1)*0.95)/3;
else
    cellSize(1)=(size(1)*0.95)/maxC;
end

% Resize all of the cells
for r=1:maxR
    for c=1:maxC

        % Get the handles for the current cell.
        panel=handles.cellPanel(r,c);
        label=handles.cellIndexLabel(r,c);
        tableDropDown=handles.tableDropDown(r,c);
        varDropDown=handles.varsDropDown(r,c);
        varEditField=handles.valueEditField(r,c);
        stButton=handles.specifyTrialsButton(r,c);
        summDropDown=handles.summMeasureDropDown(r,c);
        repVarDropDown=handles.repVarDropDown(r,c);

        % Resize
        panel.Position=[(c-1)*cellSize(1) ((maxR-(r-1))-1)*cellSize(2) cellSize];
        label.Position=round([0.43 0.9 0.25 0.1].*[cellSize cellSize]);
        tableDropDown.Position=round([0.05 0.7 0.4 0.2].*[cellSize cellSize]);
        varDropDown.Position=round([0.05 0.4 0.9 0.2].*[cellSize cellSize]);
        varEditField.Position=round([0.05 0.4 0.9 0.2].*[cellSize cellSize]);
        stButton.Position=round([0.6 0.7 0.3 0.2].*[cellSize cellSize]);
        summDropDown.Position=round([0.05 0.05 0.4 0.2].*[cellSize cellSize]);
        repVarDropDown.Position=round([0.5 0.05 0.48 0.2].*[cellSize cellSize]);

    end

end