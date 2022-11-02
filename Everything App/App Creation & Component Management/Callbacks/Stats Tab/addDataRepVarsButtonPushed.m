function []=addDataRepVarsButtonPushed(src,event)

%% PURPOSE: ADD REPETITION VARIABLES BASED ON THE DATA. THIS IS NEEDED WHEN THERE IS MORE THAN ONE VALUE PER TRIAL
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

tableNode=handles.Stats.tablesUITree.SelectedNodes;

if isempty(tableNode)
    return;
end

tableName=tableNode.Text;

%% Enter the data-driven repetition variable name
allVarNames={Stats.Tables.(tableName).RepetitionColumns.Name};
okName=false;
while ~okName
    varName=inputdlg('Enter variable name');
    
    if isempty(varName) || (iscell(varName) && isempty(varName{1}))
        disp('Process cancelled, no variable added');
        return;
    end

    if iscell(varName)
        varName=varName{1};
    end

    varName=strtrim(varName);
    varName(isspace(varName))='_'; % Replace spaces with underscores

    if ~isvarname(varName)
        beep;
        disp('Try again, invalid variable name! Spaces are ok here, but otherwise must evaluate to valid MATLAB variable name!');
        continue;
    end

    if length(varName)>namelengthmax
        beep;
        disp(['Try again, variable name too long! Must be less than or equal to ' num2str(namelengthmax) ' characters, but is currently ' num2str(length(varName)) ' characters!']);
        continue;
    end

    % Check if this component name already exists in the list.
    idx=ismember(allVarNames,varName);
    if any(idx)
        disp('This variable already exists! No variable added, terminating the process.');
        return;
    end

    okName=true;
end

%% Make the variable appear in the list of repetition variables
idx=length({Stats.Tables.(tableName).RepetitionColumns.Name})+1; % Including the newly added variable
Stats.Tables.(tableName).RepetitionColumns(idx).Name=varName;

Stats.Tables.(tableName).RepetitionColumns(idx).Mult.PerTrial=1;
Stats.Tables.(tableName).RepetitionColumns(idx).Mult.Categories={};
Stats.Tables.(tableName).RepetitionColumns(idx).Mult.DataVars={};

setappdata(fig,'Stats',Stats);

makeAssignedVarsNodes(fig,Stats,tableName);