function []=createTableButtonPushed(src,event)

%% PURPOSE: CREATE A NEW STATS TABLE. A STATS TABLE IS A UNIQUE COMBINATION OF VARIABLE COLUMNS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(Stats) || ~isfield(Stats,'Tables')
    allTablesNames='';
else
    allTablesNames=fieldnames(Stats.Tables);
end

okName=false;
while ~okName
    tableName=input('Enter table name: '); % Avoids the inputdlg
    
    if isempty(tableName) || (iscell(tableName) && isempty(tableName{1}))
        disp('Process cancelled, no table added');
        return;
    end

    if iscell(tableName)
        tableName=tableName{1};
    end

    tableName=strtrim(tableName);
    tableName(isspace(tableName))='_'; % Replace spaces with underscores

    if ~isvarname(tableName)
        beep;
        disp('Try again, invalid table name! Spaces are ok here, but otherwise must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(tableName)>namelengthmax
        beep;
        disp(['Try again, table name too long! Must be less than or equal to ' num2str(namelengthmax) ' characters, but is currently ' num2str(length(tableName)) ' characters!']);
        continue;
    end

    % Check if this component name already exists in the list.
    idx=ismember(allTablesNames,tableName);
    if any(idx)
        disp('This plot already exists! No plots added, terminating the process.');
        return;
    end

    okName=true;
end

%% Add the table name to the list of table names
Stats.Tables.(tableName)=struct();

tableNames=fieldnames(Stats.Tables);
[~,idx]=sort(upper(tableNames));
tableNames=tableNames(idx);
vals=repmat({''},1,length(tableNames));
args=[tableNames'; vals];
orderedStruct=struct(args{:});

Stats.Tables=orderfields(Stats.Tables,orderedStruct);
tableNames=fieldnames(Stats.Tables);

setappdata(fig,'Stats',Stats);

makeTableNodes(fig,1:length(tableNames),tableNames);

% Create the "Repetition" & "Data" uitreenodes in the assignedVarsUITree
repNode=uitreenode(handles.Stats.assignedVarsUITree,'Text','Repetition');
dataNode=uitreenode(handles.Stats.assignedVarsUITree,'Text','Data');

tableNode=findobj(handles.Stats.tablesUITree,'Text',tableName);
handles.Stats.tablesUITree.SelectedNodes=tableNode;
tablesUITreeSelectionChanged(fig);