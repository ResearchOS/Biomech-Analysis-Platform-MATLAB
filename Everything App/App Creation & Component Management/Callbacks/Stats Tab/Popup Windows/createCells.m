function []=createCells(fig,pubTable,allTables,pgui)

%% PURPOSE: CREATE THE CELLS FOR THE EDIT TABLE POPUP WINDOW.
handles=getappdata(fig,'handles');

cells=pubTable.Cells;

delete(handles.tablePanel.Children);

r=pubTable.Size.numRows;
c=pubTable.Size.numCols;

if r>=3
    cellSize(2)=140;
else
    cellSize(2)=429/r;
end

if c>=3
    cellSize(1)=193;
else
    cellSize(1)=579/c;
end
% cellSize=[200 200];

tableNames=fieldnames(allTables);
for i=r:-1:1 % Doing it this way because in order to scroll, all items must be "above and to the right" of the uipanel

    for j=1:c

        currCell=cells(i,j); % Metadata for the objects for each cell

        if isnumeric(currCell.value)
            currCell.value=num2str(currCell.value);
        end

        % Create the cell panel
        handles.cellPanel(i,j)=uipanel(handles.tablePanel,'BackgroundColor',[0.85 0.85 0.85],'Position',[(j-1)*cellSize(1) ((r-(i-1))-1)*cellSize(2) cellSize],'Tag',['(' num2str(i) ',' num2str(j) ')']);

        %         handles.literalCheckbox(i,j)=uicheckbox(handles.cellPanel(i,j),'Value',currCell.isLiteral,'Tooltip','Check for hard-coded value','Text','Literal','Position',round([0.05 0.8 0.4 0.1].*[cellSize cellSize]));        
        % Create the graphics objects for this cell
        handles.cellIndexLabel(i,j)=uilabel(handles.cellPanel(i,j),'Text',handles.cellPanel(i,j).Tag,'Position',round([0.43 0.9 0.25 0.1].*[cellSize cellSize]),'FontWeight','bold');
        handles.specifyTrialsButton(i,j)=uibutton(handles.cellPanel(i,j),'push','Text','ST','Position',round([0.6 0.7 0.3 0.2].*[cellSize cellSize]));
        set(handles.specifyTrialsButton(i,j),'ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushedPubTable(pgui,handles.specifyTrialsButton(i,j)));
        tableItems=[{'Literal'}; tableNames];
        handles.tableDropDown(i,j)=uidropdown(handles.cellPanel(i,j),'Items',tableItems,'Position',round([0.05 0.7 0.4 0.2].*[cellSize cellSize]),'ValueChangedFcn',@(tableDropDown,event) tableDropDownValueChanged(tableDropDown,allTables),'Value',currCell.tableName);
        if isequal(handles.tableDropDown(i,j).Value,'Literal')
            vis=true;
            varItems={''};
        else
            vis=false;            
            varItems={allTables.(handles.tableDropDown(i,j).Value).DataColumns.Name};
        end        
        handles.varsDropDown(i,j)=uidropdown(handles.cellPanel(i,j),'Items',varItems,'Position',round([0.05 0.4 0.9 0.2].*[cellSize cellSize]),'Visible',~vis,'Value',currCell.varName);
        handles.valueEditField(i,j)=uieditfield(handles.cellPanel(i,j),'Value',currCell.value,'Position',round([0.05 0.4 0.9 0.2].*[cellSize cellSize]),'Visible',vis);
        handles.summMeasureDropDown(i,j)=uidropdown(handles.cellPanel(i,j),'Items',{'Mean ± Stdev','Median ± IQR'},'Value',currCell.summMeasure,'Position',round([0.05 0.05 0.8 0.2].*[cellSize cellSize]),'Value',currCell.summMeasure);

    end

end

setappdata(fig,'handles',handles);