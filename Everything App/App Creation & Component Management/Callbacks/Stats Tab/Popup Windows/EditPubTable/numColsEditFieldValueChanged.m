function []=numColsEditFieldValueChanged(src,event)

%% PURPOSE: CHANGE THE NUMBER OF COLUMNS IN THE PUB TABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTable=getappdata(fig,'pubTable');

numCols=handles.numColsEditField.Value;

prevNumCols=currTable.Size.numCols;
numRows=currTable.Size.numRows;

if numCols<=0
    disp('Must be positive!');
    handles.numColsEditField.Value=currTable.Size.numCols;
    return;
end

if numCols==currTable.Size.numCols
    disp('Nothing changed');
    return;
end

if numCols<currTable.Size.numCols
    % Display warning message that data will be lost.
    currTable.Cells(:,numCols+1:prevNumCols)=[];
end

pguiFig=findall(0,'Name','pgui');
Stats=getappdata(pguiFig,'Stats');
allTables=Stats.Tables;

if numCols>prevNumCols
    for i=1:numRows
        for j=prevNumCols+1:numCols        
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

currTable.Size.numCols=numCols;

setappdata(fig,'pubTable',currTable);

createCells(fig,currTable,allTables,pguiFig);

% Do this so that the SpecifyTrials can be updated.
pubTableEditWindowDeleteFcn(fig,pguiFig);