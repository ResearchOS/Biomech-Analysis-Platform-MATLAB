function []=numRowsEditFieldValueChanged(src,event)

%% PURPOSE: MODIFY THE NUMBER OF ROWS IN THE PUB TABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTable=getappdata(fig,'pubTable');

numRows=handles.numRowsEditField.Value;

prevNumRows=currTable.Size.numRows;
numCols=currTable.Size.numCols;

if numRows<=0
    disp('Must be positive!');
    handles.numRowsEditField.Value=currTable.Size.numRows;
    return;
end

if numRows==currTable.Size.numRows
    disp('Nothing changed');
    return;
end

if numRows<currTable.Size.numRows
    % Display warning message that data will be lost.
    currTable.Cells(numRows+1:prevNumRows,:)=[];
end

pguiFig=findall(0,'Name','pgui');
Stats=getappdata(pguiFig,'Stats');
allTables=Stats.Tables;

if numRows>prevNumRows
    for i=prevNumRows+1:numRows
        for j=1:numCols
%             currTable.Cells(i,j).isLiteral=0;
            currTable.Cells(i,j).summMeasure='Mean ± Stdev';
            currTable.Cells(i,j).value='0';
            tableNames=fieldnames(Stats.Tables);
            currTable.Cells(i,j).tableName=tableNames{1};
            currTable.Cells(i,j).SpecifyTrials='';
            currTable.Cells(i,j).varName=Stats.Tables.(tableNames{1}).DataColumns(1).GUINames;
        end
    end
end

currTable.Size.numRows=numRows;

setappdata(fig,'pubTable',currTable);

createCells(fig,currTable,allTables,pguiFig);

% Do this so that the SpecifyTrials can be updated.
pubTableEditWindowDeleteFcn(fig,pguiFig);