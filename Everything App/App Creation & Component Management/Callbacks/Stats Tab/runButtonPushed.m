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

setappdata(fig,'tabName','Stats');

disp('Generating stats table');

%% Create the current stats table
assignin('base','gui',fig);
[statsTable,numRepCols,numDataCols,repNames,dataNames]=generateStatsTable(fig,Stats,tableName);

currDate=char(datetime('now','TimeZone','America/New_York'));
% currDate=currDate(1:11);
tableSaveName=[tableName '_' currDate];
tableSaveName=strrep(tableSaveName,'-','');
tableSaveName=strrep(tableSaveName,':','');
tableSaveName=strrep(tableSaveName,' ','_');
tableSaveName=genvarname(tableSaveName);

slash=filesep;

matFileName=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];

varNames={'Trial Name', repNames{:}, 'Trial Number', dataNames{:}};
statsTable=[varNames; statsTable];
varOut.(tableSaveName)=statsTable;

if exist(matFileName,'file')~=2
    save(matFileName,'-struct','varOut','-v6');
else
    save(matFileName,'-struct','varOut','-append');
end

xlsFolder=[getappdata(fig,'dataPath') 'Statistics' slash 'Excel Files'];
if ~isfolder(xlsFolder)
    mkdir(xlsFolder);
end

xlsFileName=[xlsFolder slash tableSaveName '.xlsx'];

%% Before writing to Excel (after saving to .mat), replace the NaN that were computed with {'NaN'} so that Excel shows NaN instead of empty cells.
% Empty cells are reserved for missing data.
missingIdx=contains(statsTable(:,1),'Missing');
statsTableData=[zeros(1,numDataCols); cell2mat(statsTable(2:end,end-numDataCols+1:end))]; % Convert to matrix
nanIdx=isnan(statsTableData); % Look for NaN

replNaNIdx=false(size(statsTable));
replNaNIdx(:,end-numDataCols+1:end)=nanIdx & ~missingIdx; % NaN's should be visible in Excel when the data is not missing, but is NaN.

statsTable(replNaNIdx)={'NaN'};
writecell(statsTable,xlsFileName,'Sheet','1','Range','A1');

disp(['Stats table generated: ' xlsFileName]);