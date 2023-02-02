function [allFcnNames,allInputVars,allOutputVars]=checkDeps(inputVarsIn,allFcnNames,allInputVars,allOutputVars,fig)

%% PURPOSE: CHECK THAT ALL DEPENDENCIES ARE UP TO DATE FOR THE SPECIFIED PROCESS FUNCTIONS
% All fcnNames are Process objects.

% NOTE: ONLY OPERATING ON ONE VERSION AT A TIME HERE (ONE COLUMN).

for i=1:length(inputVarsIn) % Get the outputting function for the input variable

    inputVar=inputVarsIn{i};    

    % Load the variable
    varPath=getClassFilePath(inputVar,'Variable');
    varStruct=loadJSON(varPath);

    % Load the function
    fcnNames=varStruct.OutputOfProcess; % Functions from which this variable was output.

    if isempty(fcnNames)
        continue; % End of the current input variable's branch.
    end

    for fcnNum=1:length(fcnNames)
        fcnName=fcnNames{fcnNum};        

        if ismember(fcnName,allFcnNames) 
            continue; % This function has been done before.
        end

%         disp(['Fcn ' fcnName ' Input Var ' inputVar]);
    
        allFcnNames=[{fcnName}; allFcnNames]; % Cell array of all function names for all input variables.
    
        fcnPath=getClassFilePath(fcnName,'Process');
        fcnStruct=loadJSON(fcnPath);

        % Single source of truth!
        inputVars=getVarNamesArray(fcnStruct,'InputVariables');
        outputVars=getVarNamesArray(fcnStruct,'OutputVariables');
    
        allInputVars=[{inputVars}; allInputVars];
        allOutputVars=[{outputVars}; allOutputVars];
    
        overwrittenIdx=ismember(inputVars,outputVars);
        % If an overwritten variable were included, the logic would be circular and never end.
        inputVars(overwrittenIdx)=[];
    
        [allFcnNames,allInputVars,allOutputVars]=checkDeps(inputVars,allFcnNames,allInputVars,allOutputVars);
    
    end

end

st=dbstack;
if isequal(st(2).name,mfilename)
    return;
end

%% Not recursive. Remove the functions whose outputs are not used, continue until everything is used.
outputsUsedIdx=false(size(allFcnNames));
outputsUsedIdx(end)=true;
runWhile=true;
allNames=[allFcnNames allInputVars allOutputVars]; % So that only one index is needed.
while runWhile    

    allOutputVars=allNames(:,3);
    allInputVars=allNames(:,2);
    allFcnNames=allNames(:,1);

    for i=1:length(allFcnNames)-1 % The last one is the function of interest, never exclude that one.

        fcnName=allFcnNames{i};

        outputVarsUsedIdx=varsUsedInFunctions(allOutputVars{i},allInputVars,'any');

        if any(outputVarsUsedIdx)
            outputsUsedIdx(i)=true;
        end

    end

    if all(outputsUsedIdx)
        break;
    end

    allNames(~outputsUsedIdx,:)=[];

    outputsUsedIdx=false(size(allNames,1),1);
    outputsUsedIdx(end)=true;

end

allOutputVars=allNames(:,3);
allInputVars=allNames(:,2);
allFcnNames=allNames(:,1);

%% Put the functions in order.
fcnNamesOrdered=cell(size(allFcnNames));
inputVarsOrdered=cell(size(allFcnNames));
outputVarsOrdered=cell(size(allFcnNames));
[fcnNamesOrdered{:}]=deal('');
[inputVarsOrdered{:}]=deal('');
[outputVarsOrdered{:}]=deal('');
% fcnNamesOrdered{end}=allFcnNames{end}; % The function of interest.
fcnNums=zeros(size(fcnNamesOrdered));

% Determine which functions are based only on hard-coded and logsheet variables. Those variables will be the ones to start with.
startFcnsIdx=false(size(allFcnNames));
for i=1:length(startFcnsIdx)
    if isStartFcn(allInputVars{i})
        startFcnsIdx(i)=true;
    end
end

fcnNamesOrdered(1:sum(startFcnsIdx))=allFcnNames(startFcnsIdx);
inputVarsOrdered(1:sum(startFcnsIdx))=allInputVars(startFcnsIdx);
outputVarsOrdered(1:sum(startFcnsIdx))=allOutputVars(startFcnsIdx);

nextIdx=length(fcnNamesOrdered)-sum(cellfun(@isempty,fcnNamesOrdered))+1;

while nextIdx<length(fcnNamesOrdered) % Keep going until everything is filled in.

    nextIdx=length(fcnNamesOrdered)-sum(cellfun(@isempty,fcnNamesOrdered))+1;
    disp(num2str(nextIdx));

    for i=1:length(allFcnNames)-1

        fcnName=allFcnNames{i};
        if ismember(fcnName,fcnNamesOrdered)
            continue; % This function has already been placed.
        end

        fcnInputVars=allInputVars{i};      
        delIdx=false(size(fcnInputVars));
        for varNum=1:length(fcnInputVars)
            [name,id]=deText(fcnInputVars{varNum});
            piText=[name '_' id];
            varStructPI=getappdata(fig,piText);
            varStructPS=getappdata(fig,fcnInputVars{varNum});

            if isempty(varStructPS.OutputOfProcess)
                varStructPS.OutputOfProcess={''}; % When empty it's not a cell (because of JSON import) and that messes with ismember
            end

            if varStructPI.IsHardCoded || isempty(varStructPS.OutputOfProcess{1}) || ...
                    (ismember(fcnName,varStructPS.InputToProcess) && ismember(fcnName,varStructPS.OutputOfProcess))
                delIdx(varNum)=true; % Remove logsheet AND hard-coded input variables.
            end
        end

        fcnInputVars(delIdx)=[];

        inputVarsUsed=varsUsedInFunctions(fcnInputVars,outputVarsOrdered,'all');

        if ~inputVarsUsed
            continue;
        end

        fcnNamesOrdered{nextIdx}=fcnName;
        inputVarsOrdered(nextIdx)=allInputVars(i);
        outputVarsOrdered(nextIdx)=allOutputVars(i);

        break;

    end

end

fcnNamesOrdered(end)=allFcnNames(end);
inputVarsOrdered(end)=allInputVars(end);
outputVarsOrdered(end)=allOutputVars(end);

end

%% PURPOSE: DETERMINE IF THE SPECIFIED VARIABLES ARE HARD-CODED/LOGSHEET INPUT VARIABLES ONLY.
function [bool]=isStartFcn(varNames)

    bool=true;
    for i=1:length(varNames)
        varPath=getClassFilePath(varNames{i},'Variable');
        varStruct=loadJSON(varPath);

        if ~isempty(varStruct.OutputOfProcess)
            bool=false;
            return;
        end
    end

end
