function [runInfo]=getRunInfo(piStruct,psStruct)

%% PURPOSE: COMPILE INFO THAT GETARG/SETARG NEED TO RUN THE SPECIFIED FUNCTION.

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');
fullPath=getClassFilePath(Current_Project_Name, 'Project');
projectStruct=loadJSON(fullPath);

computerID=getComputerID();
runInfo.DataPath=projectStruct.DataPath.(computerID);

% Store the info for the function to run.
runInfo.Fcn.PIStruct=piStruct;
runInfo.Fcn.PSStruct=psStruct;

if isequal(piStruct.Class,'Process')
    numIters=2;
else
    numIters=1;
end

% Store the info for each variable.
for inOut=1:numIters

    switch inOut
        case 1
            fldName='Input';
        case 2
            fldName='Output';
    end

    vars=psStruct.([fldName 'Variables']);
    varNamesInCode=piStruct.([fldName 'VariablesNamesInCode']);

    if isempty(varNamesInCode)
        error('Missing Variables Names In Code!');
    end
    
    assert(length(vars)==length(varNamesInCode),['Mismatch in number of getArgs! ' psStruct.Text]);
    assert(~isempty(vars),['Missing ' lower(fldName) ' arguments to run the function! ' psStruct.Text])
    for i=1:length(vars)
        assert(length(vars{i})==length(varNamesInCode{i}),['Mismatch in number of variables in getArg ' num2str(vars{i}{1}) ' ' psStruct.Text]);
        for j=2:length(vars{i})
            
            currVarPS=vars{i}{j};
            filePathPS=getClassFilePath_PS(currVarPS, 'Variable');
            varStructPS=loadJSON(filePathPS);   

            currVarPI=getPITextFromPS(currVarPS);
            filePathPI=getClassFilePath(currVarPI, 'Variable');
            varStructPI=loadJSON(filePathPI);

            runInfo.Var.(fldName)(i).PSStruct{j-1}=varStructPS;
            runInfo.Var.(fldName)(i).PIStruct{j-1}=varStructPI;
        end
    end

end

runInfo.Class=piStruct.Text;

if ~isequal(piStruct.Class,'Component')
    assignin('base','runInfo',runInfo);
end