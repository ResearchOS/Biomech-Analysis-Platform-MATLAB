function [allFcnNames,allInputVars,allOutputVars]=checkDeps(inputVars,allFcnNames,allInputVars,allOutputVars)

%% PURPOSE: CHECK THAT ALL DEPENDENCIES ARE UP TO DATE FOR THE SPECIFIED PROCESS FUNCTIONS
% All fcnNames are Process objects.

% NOTE: ONLY OPERATING ON ONE VERSION AT A TIME HERE (ONE COLUMN).

% if exist('allFcnNames','var')~=1
%     allFcnNames={};
% end
% 
% if exist('allInputVars','var')~=1
%     allInputVars={};
% end
% 
% if exist('allOutputVars','var')~=1
%     allOutputVars={};
% end

for i=1:length(inputVars) % Get the outputting function for the input variable

    inputVar=inputVars{i};

    % Load the variable
    varPath=getClassFilePath(inputVar,'Variable');
    varStruct=loadJSON(varPath);

    % Load the function
    fcnNames=varStruct.BackwardLinks_Process; % Functions from which this variable was output.

    if length(fcnNames)==1 && ismember(fcnNames,{'HardCoded','Logsheet'}) % Indicates that we've reached the end of the line.
        continue;
    end

    for fcnNum=1:length(fcnNames)
        fcnName=fcnNames{fcnNum};

        if ismember(fcnName,allFcnNames) % This function has been done before.
            continue;
        end
    
        allFcnNames=[{fcnName}; allFcnNames]; % Cell array of all function names for all input variables.
    
        fcnPath=getClassFilePath(fcnName,'Process');
        fcnStruct=loadJSON(fcnPath);
    
        inputVars=fcnStruct.BackwardLinks_Variable;
        outputVars=fcnStruct.ForwardLinks_Variable;
    
        allInputVars=[{inputVars}; allInputVars];
        allOutputVars=[{outputVars}; allOutputVars];
    
        overwrittenIdx=ismember(inputVars,outputVars);
        % If an overwritten variable were included, the logic would be circular and never end.
        % BUT I don't just want to know when the variable was overwritten, I want to know where it is first created!
        % MORE WORK NEEDED HERE
        inputVars(overwrittenIdx)=[];
    
        [allFcnNames,allInputVars,allOutputVars]=checkDeps(inputVars,allFcnNames,allInputVars,allOutputVars);
    
    end

end

































% for i=1:size(allFcnNames,1)
% 
%     fcnNames=allFcnNames{i};
% 
%     fcnPath=getClassFilePath(fcnNames{1},'Process');
%     fcnStruct=loadJSON(fcnPath);
%     if isfield(fcnStruct,'BackwardLinks_Variable') % Input variables
%         inputVars=fcnStruct.BackwardLinks_Variable;
%     else
%         inputVars={};
%     end
%     if isfield(fcnStruct,'ForwardLinks_Variable') % Output variables.
%         outputVars=fcnStruct.ForwardLinks_Variable;
%     else
%         outputVars={};
%     end
% 
%     allInputVars{i}=inputVars;
%     allOutputVars{i}=outputVars;
% 
%     % Need to recursively investigate the dependencies for each variable in each function.
% 
% end








































% 1. Be sure to only look at process functions that are within the current
% process group.

% projectSettingsFile=getProjectSettingsFile();
% Current_ProcessGroup_Name=loadJSON(projectSettingsFile,'Current_ProcessGroup_Name');
% processGroup=Current_ProcessGroup_Name;
%
% for i=1:length(texts)
%
%     text=texts{i};
%
%     fullPath=getClassFilePath(text, 'Process');
%     processStruct=loadJSON(fullPath);
%
%     % The date that the process function was modified.
%     % If after the date that any of the input variables were modified, then
%     % add this process function to the list.
%     processDateModified=processStruct.DateModified;
%
%     varNames=getVarNamesArray(processStruct,'InputVariables');
%
%     for j=1:length(varNames)
%
%         varName=varNames{j};
%         varPath=getClassFilePath(varName,'Variable');
%         varStruct=loadJSON(varPath);
%
%         varProcessNames=varStruct.ForwardLinks_Process; % The process structs that use this variable.
%
%     end
%
% end