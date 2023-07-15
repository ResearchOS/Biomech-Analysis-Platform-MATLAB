function [runInfo]=getRunInfo(absStruct,instStruct)

%% PURPOSE: COMPILE INFO THAT GETARG/SETARG NEED TO RUN THE SPECIFIED FUNCTION.

Current_Project_Name = getCurrent('Current_Project_Name');
projectStruct=loadJSON(Current_Project_Name);

computerID=getComputerID();
runInfo.DataPath=projectStruct.DataPath.(computerID);

% Store the info for the function to run.
runInfo.Fcn.AbsStruct=absStruct;
runInfo.Fcn.InstStruct=instStruct;

[fcnType] = deText(absStruct);

if isequal(fcnType,'Process')
    numIters=2; % Input and output variables.
else
    numIters=1; % Inputs only.
end

% Store the info for each variable.
for inOut=1:numIters

    switch inOut
        case 1
            fldName='Input';
        case 2
            fldName='Output';
    end

    vars=instStruct.([fldName 'Variables']);
    varNamesInCode=absStruct.([fldName 'VariablesNamesInCode']);

    if isempty(varNamesInCode)
        error(['Missing ' fldName ' Variables Names In Code!']);
    end
    
    assert(length(vars)==length(varNamesInCode),['Mismatch in number of getArgs! ' instStruct.UUID]);
    assert(~isempty(vars),['Missing ' lower(fldName) ' arguments to run the function! ' instStruct.UUID])
    for i=1:length(vars)
        assert(length(vars{i})==length(varNamesInCode{i}),['Mismatch in number of variables in getArg ' num2str(vars{i}{1}) ' ' instStruct.UUID]);
        for j=2:length(vars{i})
            
            currVarInst=vars{i}{j};            
            varStructInst=loadJSON(currVarInst);   

            [type, abstractID, instanceID] = deText(currVarInst);
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