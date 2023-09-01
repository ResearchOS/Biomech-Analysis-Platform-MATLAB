function [runInfo]=getRunInfo(absStruct,instStruct)

%% PURPOSE: COMPILE INFO THAT GETARG/SETARG NEED TO RUN THE SPECIFIED FUNCTION.
% 1. Data path
% 2. The abstract & instance structs.
% 3. Map the names in code to the variable names.

global conn;

runInfo.DataPath=getCurrent('Data_Path');

% Store the info for the function to run.
runInfo.Fcn.AbsStruct=absStruct;
runInfo.Fcn.InstStruct=instStruct;

[fcnType] = deText(absStruct.UUID);

if isequal(fcnType,'PR')
    numIters=2; % Input and output variables.
else
    numIters=1; % Inputs only.
end

% Store the info for each variable.
for inOut=1:numIters

    switch inOut
        case 1
            fldName='Input';
            tablename = 'VR_PR';
        case 2
            fldName='Output';
            tablename = 'PR_VR';
    end

    sqlquery = ['SELECT VR_ID, NameInCode FROM ' tablename ' WHERE PR_ID = ' instStruct.UUID];
    t = fetch(conn, sqlquery);
    tJoin = table2MyStruct(t);

    varStr = getCondStr(tJoin.VR_ID);
    sqlquery = ['SELECT * FROM ' tablename ' WHERE UUID IN ' varStr];
    t = fetch(conn, sqlquery);
    vrStructs = table2MyStruct(t,'struct');
    vrUUIDs = {vrStructs.UUID};

    varNamesInCode=absStruct.([fldName 'VariablesNamesInCode']); % Cell array of cell arrays.

    if isempty(varNamesInCode)
        continue; % For plotting (when making them process functions)
%         error(['Missing ' fldName ' Variables Names In Code!']);
    end
    
    % assert(length(vars)==length(varNamesInCode),['Mismatch in number of getArgs! ' instStruct.UUID]);
    % assert(~isempty(vars),['Missing ' lower(fldName) ' arguments to run the function! ' instStruct.UUID])
    for i=1:length(varNamesInCode)
        % assert(length(vars{i})==length(varNamesInCode{i}),['Mismatch in number of variables in getArg ' num2str(vars{i}{1}) ' ' instStruct.UUID]);
        for j=2:length(varNamesInCode{i})
            
            idx = ismember(vrUUIDs,varNamesInCode{i}{j});            
            varStructInst=vrStructs(idx);   

            [type, abstractID, instanceID] = deText(varStructInst.UUID);
            currVarAbs = genUUID(type, abstractID);                        
            varStructAbs=loadJSON(currVarAbs);

            runInfo.Var.(fldName)(i).InstStruct{j-1}=varStructInst;
            runInfo.Var.(fldName)(i).AbsStruct{j-1}=varStructAbs;
        end
    end

end

runInfo.Class=className2Abbrev(fcnType, true);

if ~isequal(fcnType,'Component')
    assignin('base','runInfo',runInfo);
end