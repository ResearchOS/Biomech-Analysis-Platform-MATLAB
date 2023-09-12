function [bool,logVar]=checkLogsheetSetup(src)

%% PURPOSE: ENSURE THAT THE LOGSHEET HAS EVERYTHING IT NEEDS TO RUN SPECIFY TRIALS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

logVar = {};
Current_Logsheet = getCurrent('Current_Logsheet');

if isempty(Current_Logsheet)
    disp('Select a logsheet in the UI tree!');
    bool=false;
    return;
end

logsheetStruct=loadJSON(Current_Logsheet);

computerID=getComputerID();

slash = filesep;
bool=true;
try

    errorData=[]; % For error reporting.

    % 1. Logsheet path.
    assert(isfield(logsheetStruct.Logsheet_Path,computerID),'Logsheet path not  found on this computer.');
    path=logsheetStruct.Logsheet_Path.(computerID);
    assert(exist(path,'file')==2,'Logsheet path not found');

    % 2. Logsheet path MAT.
    [folder,name]=fileparts(path);
    pathMAT=[folder slash name '.mat'];
    assert(exist(pathMAT,'file')==2,'Logsheet MAT file path not found');
    load(pathMAT,'logVar');
    headersFirstRow=logVar(1,:)';

    params = logsheetStruct.LogsheetVar_Params;
    headers = {params.Headers}';
    level = {params.Level}';
    type = {params.Type}';

    % 3. Check that headers have not changed.
    assert(isequal(headersFirstRow,headers),'Headers have changed');
    assert(length(headers)==length(type),'Headers & type mismatch');
    assert(length(headers)==length(level),'Headers & level mismatch');
    assert(length(type)==length(level),'Type & level mismatch');

    % 4. Check that the headers are all valid variable names.
    assert(all(cellfun(@isvarname, headersFirstRow)));

    % 1. Num Header Rows
    assert(isa(logsheetStruct.Num_Header_Rows,'double'),'NumHeaderRows must be a positive integer double!');
    assert(mod(logsheetStruct.Num_Header_Rows,1)==0,'NumHeaderRows must be a positive integer');
    assert(logsheetStruct.Num_Header_Rows>0,'NumHeaderRows must be positive');

    % 2. Subject Codename Header
    assert(isa(logsheetStruct.Subject_Codename_Header,'char'));
    assert(~isempty(logsheetStruct.Subject_Codename_Header));
    assert(any(ismember(logsheetStruct.Subject_Codename_Header,headers)));

    % 7. Check that all subject codenames are valid variable names.
    codenameHeaderIdx=ismember(headers,logsheetStruct.Subject_Codename_Header);
    codenames=logVar(logsheetStruct.Num_Header_Rows+1:end,codenameHeaderIdx);
    errorIdx=find(~cellfun(@isvarname, codenames)==1);
%     errorData=codenames(errorIdx);
%     assert(isempty(errorIdx),['Subject codenames not valid variable names in lines: ' errorIdx]);
    assert(isempty(errorIdx),'Subject codenames not valid variable names');

    % 3. Target Trial ID
    assert(isa(logsheetStruct.Target_TrialID_Header,'char'));
    assert(~isempty(logsheetStruct.Target_TrialID_Header));
    assert(any(ismember(logsheetStruct.Target_TrialID_Header,headers)));

    % 9. Check that all target trial names are valid variable names.
    targetTrialIDIdx=ismember(headers,logsheetStruct.Target_TrialID_Header);
    targetTrialNames=logVar(logsheetStruct.Num_Header_Rows+1:end,targetTrialIDIdx);
    assert(all(cellfun(@isvarname, targetTrialNames)));

catch
    beep;
    logVar=[];
    bool=false;
end