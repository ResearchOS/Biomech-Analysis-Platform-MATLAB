function [allFcnNames,allInputVars,allOutputVars]=checkDeps(inputVarsIn,allFcnNames,allInputVars,allOutputVars)

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
while runWhile    

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

    % THESE KEEP GOING OUT OF ORDER FROM ONE ANOTHER, WHY?
    allFcnNames(~outputsUsedIdx)=[];
    allInputVars(~outputsUsedIdx)=[];
    allOutputVars(~outputsUsedIdx)=[];   

    outputsUsedIdx=false(size(allFcnNames));
    outputsUsedIdx(end)=true;

end

%% Put the functions in order.
fcnNamesOrdered=cell(size(allFcnNames));
inputVarsOrdered=cell(size(allFcnNames));
outputVarsOrdered=cell(size(allFcnNames));
for i=1:length(fcnNamesOrdered)
    fcnNamesOrdered{i}='';
    inputVarsOrdered{i}='';
    outputVarsOrdered{i}='';
end
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

while any(cellfun(@isempty,fcnNamesOrdered)) % Keep going until everything is filled in.

    nextIdx=length(fcnNamesOrdered)-sum(cellfun(@isempty,fcnNamesOrdered))+1;

    for i=2:length(allFcnNames)-1

        fcnName=allFcnNames{i};
        if ismember(fcnName,fcnNamesOrdered)
            continue; % This function has already been placed.
        end

        fcnInputVars=allInputVars{i};        

        inputVarsUsed=varsUsedInFunctions(fcnInputVars,outputVarsOrdered,'all');

        if ~inputVarsUsed
            continue;
        end

        fcnNamesOrdered{nextIdx}=fcnName;
        inputVarsOrdered(nextIdx)=allInputVars(i);
        outputVarsOrdered(nextIdx)=allOutputVars(i);






%         inputVarsUsedIdxNums=cell(size(fcnInputVars));
%         for j=1:length(fcnInputVars)
% 
%             inputVarsUsed=varsUsedInFunctions(fcnInputVars(j),allOutputVars); % Which functions is the current input variable used in?
%             inputVarsUsedIdxNums{j}=find(inputVarsUsed==1);
% 
%         end

    end

end

fcnOfIntIdxNum=find(ismember(fcnNamesOrdered,allFcnNames{end})==1);
if isempty(fcnOfIntIdxNum)
    fcnNamesOrdered(end)=allFcnNames(end);
    inputVarsOrdered(end)=allInputVars(end);
    outputVarsOrdered(end)=allOutputVars(end);
else    
    fcnNamesOrdered([end fcnOfIntIdxNum])=allFcnNames([fcnOfIntIdxNum end]);
    inputVarsOrdered([end fcnOfIntIdxNum])=allInputVars([fcnOfIntIdxNum end]);
    outputVarsOrdered([end fcnOfIntIdxNum])=allOutputVars([fcnOfIntIdxNum end]);
end

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
