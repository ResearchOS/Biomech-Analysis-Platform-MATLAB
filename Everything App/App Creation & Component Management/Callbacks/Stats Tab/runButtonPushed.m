function []=runButtonPushed(src,event)

%% PURPOSE: CREATE THE STATS TABLE WITH THE CURRENT SETTINGS, AND SAVE IT TO .MAT VARIABLE AND EXCEL FILE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');
projectName=getappdata(fig,'projectName');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

repDataNodes=handles.Stats.assignedVarsUITree.Children;

assert(isequal(repDataNodes(1).Text,'Repetition'));
assert(isequal(repDataNodes(2).Text,'Data'));

if isempty(repDataNodes(1).Children) || isempty(repDataNodes(2).Children)
    disp('Must have variables in both sections to produce a table!');
    return;
end

if ~isfield(Stats.Tables.(tableName),'SpecifyTrials')
    disp('Must select a SpecifyTrials first!');
    return;
end

%% Create the current stats table
statsTable=generateStatsTable(fig,Stats,tableName);

currDate=char(datetime('now','TimeZone','America/New_York'));
% currDate=currDate(1:11);
varName=[tableName '_' currDate];
varName=genvarname(varName);

matFileName=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];

varOut.(varName)=statsTable;

save(matFileName,varName,'-struct','-v6');

