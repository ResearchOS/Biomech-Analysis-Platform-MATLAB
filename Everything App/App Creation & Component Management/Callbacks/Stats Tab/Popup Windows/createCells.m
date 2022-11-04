function []=createCells(fig,pubTable)

%% PURPOSE: CREATE THE CELLS FOR THE EDIT TABLE POPUP WINDOW.
handles=getappdata(fig,'handles');

cells=pubTable.Cells;

r=pubTable.Size.numRows;
c=pubTable.Size.numCols;

if r>=3
    cellSize(1)=193;
else
    cellSize(1)=580/r;
end

if c>=3
    cellSize(2)=143;
else
    cellSize(2)=480/c;
end
% cellSize=[200 200];

for i=r:-1:1 % Doing it this way because in order to scroll, all items must be "above and to the right" of the uipanel

    for j=1:c

        currCell=cells(i,j); % Metadata for the objects for each cell

        if isnumeric(currCell.value)
            currCell.value=num2str(currCell.value);
        end

        % Create the cell panel
        handles.cellPanel(i,j)=uipanel(handles.tablePanel,'BackgroundColor',[0.85 0.85 0.85],'Position',[(r-1)*cellSize(1) (c-1)*cellSize(2) cellSize],'Tag',['(' num2str(i) ',' num2str(j) ')']);

        % Create the graphics objects for this cell
        handles.cellIndexLabel(i,j)=uilabel(handles.cellPanel(i,j),'Text',handles.cellPanel(i,j).Tag,'Position',round([0.43 0.9 0.25 0.1].*[cellSize cellSize]),'FontWeight','bold');
        handles.literalCheckbox(i,j)=uicheckbox(handles.cellPanel(i,j),'Value',currCell.isLiteral,'Tooltip','Check for hard-coded value','Text','Literal','Position',round([0.05 0.8 0.25 0.1].*[cellSize cellSize]));
        handles.specifyTrialsButton(i,j)=uibutton(handles.cellPanel(i,j),'push','Text','ST','ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushedPopupWindow(specifyTrialsButton),'Position',round([0.4 0.8 0.5 0.1].*[cellSize cellSize]));
        handles.valueEditField(i,j)=uieditfield(handles.cellPanel(i,j),'Value',currCell.value,'Position',round([0.05 0.6 0.9 0.1].*[cellSize cellSize]));
        handles.summMeasureDropDown(i,j)=uidropdown(handles.cellPanel(i,j),'Items',{'Mean ± Stdev','Median ± IQR'},'Value',currCell.summMeasure,'Position',round([0.05 0.05 0.5 0.1].*[cellSize cellSize]));

    end

end

setappdata(fig,'handles',handles);