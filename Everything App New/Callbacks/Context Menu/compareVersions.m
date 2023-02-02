function []=compareVersions(src,event)

%% PURPOSE: COMPARE MULTIPLE VERSIONS OF THE SAME COMMON OBJECT.

% disp('Not done yet!');
% return;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;

[name,id,psid]=deText(text);

if isempty(psid)
    piText=text;
else
    piText=[name '_' id];
end

uiTree=getUITreeFromNode(selNode);
structClass=getClassFromUITree(uiTree);
piPath=getClassFilePath(piText, structClass);
piStruct=loadJSON(piPath);

assert(isequal(structClass,piStruct.Class)); % Just checking that the correct class was loaded.

psTexts=piStruct.Versions;

if isempty(psTexts)
    disp('There are no versions to compare!');
    return;
end

% Get the function texts that created these variables.
if isequal(structClass,'Variable')
    fcnNames=cell(size(psTexts));
    for i=1:length(psTexts)

        psText=psTexts{i};
        psPath=getClassFilePath(psText,'Variable');
        psStruct=loadJSON(psPath);
        fcnNamesCurr=psStruct.OutputOfProcess; % This field should always exist and be populated, because that's how this variable was created.

        fcnNames{i}=[fcnNames{i}; fcnNamesCurr]; % Cell array (Nx1) of cell arrays (Mx1). Final result will have N columns of M functions, counting from bottom left. M starts here as 1

    end
    structClass='Process'; % Because now I want to aggregate all of the variables from that function, and all of their predecessor functions too.
elseif isequal(structClass,'Process') % Just want to look at all of the functions
    fcnNames=cell(size(psTexts));
    for i=1:length(size(psTexts))
        fcnName=psTexts{i};
        fcnNames{i}=[fcnNames{i}; fcnName]; % Cell array (Nx1) of cell arrays (Mx1). Final result will have N columns of M functions, counting from bottom left. M starts here as 1
    end
end

% Get the function texts (& input/output variables) that the above functions' input variables rely on.
if isequal(structClass,'Process')
    inputVars=cell(size(fcnNames));
    outputVars=cell(size(fcnNames));
    % Get the input & output variables for the first function manually. Then, use the recursive function to find the rest.
    for i=1:length(fcnNames)
        for j=1:length(fcnNames{i})
            fcnName=fcnNames{i}{j};
            fcnPath=getClassFilePath(fcnName,'Process');
            fcnStruct=loadJSON(fcnPath);
            inputVars{i}{j}=getVarNamesArray(fcnStruct,'InputVariables');
            outputVars{i}{j}=getVarNamesArray(fcnStruct,'OutputVariables');
        end
    end
    
    % The first function has already been filled in. Build from there.
    numVersions=length(fcnNames);
    for i=1:numVersions
        inputVarsVer=inputVars{i}{length(fcnNames{i})}; % Just a cell array of variable names
        [fcnNames{i},inputVars{i},outputVars{i}]=checkDeps(inputVarsVer,fcnNames{i},inputVars{i},outputVars{i});
    end
end