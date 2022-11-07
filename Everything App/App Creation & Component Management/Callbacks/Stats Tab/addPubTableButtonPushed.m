function []=addPubTableButtonPushed(src,event)

%% PURPOSE: CREATE A NEW TABLE FOR PUBLICATION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(Stats) || ~isfield(Stats,'PubTables')
    allPubTablesNames='';
else
    allPubTablesNames=fieldnames(Stats.PubTables);
end

okName=false;
while ~okName
    tableName=input('Enter pub. table name: '); % Avoids the inputdlg
    
    if isempty(tableName) || (iscell(tableName) && isempty(tableName{1}))
        disp('Process cancelled, no pub table added');
        return;
    end

    if iscell(tableName)
        tableName=tableName{1};
    end

    tableName=strtrim(tableName);
    tableName(isspace(tableName))='_'; % Replace spaces with underscores

    if ~isvarname(tableName)
        beep;
        disp('Try again, invalid pub table name! Spaces are ok here, but otherwise must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(tableName)>namelengthmax
        beep;
        disp(['Try again, pub table name too long! Must be less than or equal to ' num2str(namelengthmax) ' characters, but is currently ' num2str(length(tableName)) ' characters!']);
        continue;
    end

    % Check if this component name already exists in the list.
    idx=ismember(allPubTablesNames,tableName);
    if any(idx)
        disp('This pub table already exists! No pub table added, terminating the process.');
        return;
    end

    okName=true;
end

%% Add the pub table name to the list of pub table names
Stats.PubTables.(tableName)=struct();

% Initialize the pub table with some values
pubTable.Size.numRows=1;
pubTable.Size.numCols=1;
pubTable.SigFigs=3;
% pubTable.Cells(1,1).isLiteral=0; % 0 to be a variable, 1 to be a hard-coded value.
pubTable.Cells(1,1).summMeasure='Mean ± Stdev';
pubTable.Cells(1,1).value='0'; % This can be either a number or char (but always represented as a char to satisfy the textbox requirements). Whether that means hard-coded or not is defined by the 'isLiteral' property
pubTable.Cells(1,1).SpecifyTrials='';
tableNames=fieldnames(Stats.Tables);
pubTable.Cells(1,1).tableName=tableNames{1};
pubTable.Cells(1,1).varName=Stats.Tables.(tableNames{1}).DataColumns(1).GUINames;
pubTable.Cells(1,1).repVar='';

Stats.PubTables.(tableName)=pubTable;

tableNames=fieldnames(Stats.PubTables);
[~,idx]=sort(upper(tableNames));
tableNames=tableNames(idx);
vals=repmat({''},1,length(tableNames));
args=[tableNames'; vals];
orderedStruct=struct(args{:});

Stats.PubTables=orderfields(Stats.PubTables,orderedStruct);
tableNames=fieldnames(Stats.PubTables);

setappdata(fig,'Stats',Stats);

% Create the publication table nodes
makePubTableNodes(fig,1:length(tableNames),tableNames);

tableNode=findobj(handles.Stats.pubTablesUITree,'Text',tableName);
handles.Stats.pubTablesUITree.SelectedNodes=tableNode;

pubTablesUITreeSelectionChanged(fig);