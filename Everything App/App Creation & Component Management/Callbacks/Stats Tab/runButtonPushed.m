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
[statsTable,numRepCols,numDataCols,repNames,dataNames,numericColIdx]=generateStatsTable(fig,Stats,tableName);

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
statsTable2=statsTable;
dataColIdx=size(statsTable,2)-numDataCols+1:size(statsTable,2); % Initialize the column indices for all data variables

missingRowIdx=contains(statsTable(:,1),'Missing') & ~contains(statsTable(:,1),'Multi');
missingCellIdx=false(size(statsTable)); 
missingCellIdx(:,1)=missingRowIdx;
missingCellIdx(:,dataColIdx)=repmat(missingRowIdx,1,length(dataColIdx)); % The indices of all empty cells due to the trial being missing in that row
statsTable2(missingCellIdx)={NaN};

% Treat char/string data columns separately from numeric
%% Treat character columns.
charColIdx=dataColIdx(~ismember(dataColIdx,numericColIdx)); % Initialize column indices for character data
% Remove the 'Missing from file' message in Excel table.
charMissingFromFileCellIdx=false(size(statsTable));
for i=1:length(charColIdx)
    charMissingFromFileCellIdx(:,charColIdx(i))=ismember(statsTable(:,charColIdx(i)),{'Missing from file','NaN',''});
end
statsTable2(charMissingFromFileCellIdx)={NaN};

%% Treat numeric data columns.
% numericMissingCellIdx=false(size(statsTable));
% missingTrialRowIdx=repmat(missingRowIdx(2:end),1,length(numericColIdx)); % Which rows are missing the entire trial
% numericMissingCellIdx(2:end,numericColIdx)=isnan(cell2mat(statsTable(2:end,numericColIdx))) & ~missingTrialRowIdx; % Find where the data is NaN and the entire trial is not missing
% numericMissingCellIdx(2:end,numericColIdx)=isnan(cell2mat(statsTable(2:end,numericColIdx))); % Find where the data is NaN and the entire trial is not missing
% statsTable2(numericMissingCellIdx)={'NaN'};

writecell(statsTable2,xlsFileName,'Sheet','1','Range','A1');

disp(['Stats table generated: ' xlsFileName]);