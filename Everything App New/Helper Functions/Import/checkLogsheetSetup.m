function [bool,logVar]=checkLogsheetSetup(src)

%% PURPOSE: ENSURE THAT THE LOGSHEET HAS EVERYTHING IT NEEDS TO RUN SPECIFY TRIALS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    disp('Select a logsheet in the UI tree!');
    bool=false;
    return;
end

fullPath=getClassFilePath(selNode);
logsheetStruct=loadJSON(fullPath);

computerID=getComputerID();

bool=true;
try

    errorData=[]; % For error reporting.

    % 1. Logsheet path.
    assert(isfield(logsheetStruct.LogsheetPath,computerID),'Logsheet path not  found on this computer.');
    path=logsheetStruct.LogsheetPath.(computerID);
    assert(exist(path,'file')==2,'Logsheet path not found');

    % 2. Logsheet path MAT.
    [folder,name]=fileparts(path);
    pathMAT=[folder slash name '.mat'];
    assert(exist(pathMAT,'file')==2,'Logsheet MAT file path not found');
    load(pathMAT,'logVar');
    headers=logVar(1,:)';

    % 3. Check that headers have not changed.
    assert(isequal(headers,logsheetStruct.Headers),'Headers have changed');
    assert(length(logsheetStruct.Headers)==length(logsheetStruct.Type),'Headers & type mismatch');
    assert(length(logsheetStruct.Headers)==length(logsheetStruct.Level),'Headers & level mismatch');
    assert(length(logsheetStruct.Type)==length(logsheetStruct.Level),'Type & level mismatch');

    % 4. Check that the headers are all valid variable names.
    assert(all(cellfun(@isvarname, headers)));

    % 1. Num Header Rows
    assert(isa(logsheetStruct.NumHeaderRows,'double'),'NumHeaderRows must be a positive integer double!');
    assert(mod(logsheetStruct.NumHeaderRows,1)==0,'NumHeaderRows must be a positive integer');
    assert(logsheetStruct.NumHeaderRows>0,'NumHeaderRows must be positive');

    % 2. Subject Codename Header
    assert(isa(logsheetStruct.SubjectCodenameHeader,'char'));
    assert(~isempty(logsheetStruct.SubjectCodenameHeader));
    assert(any(ismember(logsheetStruct.SubjectCodenameHeader,logsheetStruct.Headers)));

    % 7. Check that all subject codenames are valid variable names.
    codenameHeaderIdx=ismember(logsheetStruct.Headers,logsheetStruct.SubjectCodenameHeader);
    codenames=logVar(logsheetStruct.NumHeaderRows+1:end,codenameHeaderIdx);
    errorIdx=find(~cellfun(@isvarname, codenames)==1);
%     errorData=codenames(errorIdx);
%     assert(isempty(errorIdx),['Subject codenames not valid variable names in lines: ' errorIdx]);
    assert(isempty(errorIdx),'Subject codenames not valid variable names');

    % 3. Target Trial ID
    assert(isa(logsheetStruct.TargetTrialIDHeader,'char'));
    assert(~isempty(logsheetStruct.TargetTrialIDHeader));
    assert(any(ismember(logsheetStruct.TargetTrialIDHeader,logsheetStruct.Headers)));

    % 9. Check that all target trial names are valid variable names.
    targetTrialIDIdx=ismember(logsheetStruct.Headers,logsheetStruct.TargetTrialIDHeader);
    targetTrialNames=logVar(logsheetStruct.NumHeaderRows+1:end,targetTrialIDIdx);
    assert(all(cellfun(@isvarname, targetTrialNames)));

catch
    beep;
    logVar=[];
    bool=false;
end