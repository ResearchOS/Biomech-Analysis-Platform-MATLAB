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

if ~isfield(piStruct,['ForwardLinks_' structClass])
    disp('There are no versions to compare!');
    return;
end

psTexts=piStruct.(['ForwardLinks_' structClass]);

% Get the function texts that created these variables.
if isequal(structClass,'Variable')
    fcnNames=cell(size(psTexts));
    for i=1:length(psTexts)

        psText=psTexts{i};
        psPath=getClassFilePath(psText,'Variable');
        psStruct=loadJSON(psPath);
        fcnName=psStruct.BackwardLinks_Process; % This field should always exist and be populatd, because that's how this variable was created.
        if length(fcnName)>1
            disp('How am I supposed to pick between the multiple times that this variable has been overwritten?');
            return;
        end

        fcnNames{i}=[fcnNames{i}; fcnName]; % Cell array (Nx1) of cell arrays (Mx1). Final result will have N columns of M functions, counting from bottom left. M starts here as 1

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
        fcnName=fcnNames{i}{1};
        fcnPath=getClassFilePath(fcnName,'Process');
        fcnStruct=loadJSON(fcnPath);
        inputVars{i}{1}=fcnStruct.BackwardLinks_Variable;
        outputVars{i}{1}=fcnStruct.ForwardLinks_Variable;
    end
    
    % The first function has already been filled in. Build from there.
    numVersions=length(fcnNames);
    for i=1:numVersions
        inputVarsVer=inputVars{i}{1}; % Just a cell array of variable names
        [fcnNames{i},inputVars{i},outputVars{i}]=checkDeps(inputVarsVer,fcnNames{i},inputVars{i},outputVars{i});
%         fcnNames{i}=[allFcnNames; fcnNames{i}];
%         inputVars{i}=[allInputVars; inputVars{i}];
%         outputVars{i}=[allOutputVars; outputVars{i}];
    end
end