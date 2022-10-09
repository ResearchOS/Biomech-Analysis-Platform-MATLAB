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

disp('Generating stats table');

%% Create the current stats table
[statsTable,numRepCols,numDataCols,repNames,dataNames]=generateStatsTable(fig,Stats,tableName);

currDate=char(datetime('now','TimeZone','America/New_York'));
% currDate=currDate(1:11);
varName=[tableName '_' currDate];
varName=strrep(varName,'-','');
varName=strrep(varName,':','');
varName=strrep(varName,' ','_');
varName=genvarname(varName);

slash=filesep;

matFileName=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];

varNames={'Trial Name', repNames{:}, 'Trial Number', dataNames{:}};
statsTable=[varNames; statsTable];
varOut.(varName)=statsTable;

if exist(matFileName,'file')~=2
    save(matFileName,'-struct','varOut','-v6');
else
    save(matFileName,'-struct','varOut','-append');
end

xlsFolder=[getappdata(fig,'dataPath') 'Statistics' slash 'Excel Files'];
if ~isfolder(xlsFolder)
    mkdir(xlsFolder);
end

xlsFileName=[xlsFolder slash varName '.xlsx'];

writecell(statsTable,xlsFileName,'Sheet','1','Range','A1');
