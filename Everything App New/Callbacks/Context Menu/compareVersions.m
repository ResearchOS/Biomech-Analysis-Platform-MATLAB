function []=compareVersions(src,event)

%% PURPOSE: COMPARE MULTIPLE VERSIONS OF THE SAME COMMON OBJECT.

disp('Not done yet!');
return;

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

        fcnNames{i,1}=fcnName; % Cell array, currently size Nx1. Starts from bottom left, "i" is the column number from left to right, "1" is the row number bottom to top.

    end
    structClass='Process'; % Because now I want to aggregate all of the variables from that function, and all of their predecessor functions too.
elseif isequal(structClass,'Process') % Just want to look at all of the functions
    fcnNames=psTexts;
end

% Get the function texts (& input/output variables) that the above functions' input variables rely on.
if isequal(structClass,'Process')
    allInputVars=cell(size(fcnNames));
    allOutputVars=cell(size(fcnNames));
    for i=1:size(fcnNames,1)

        fcnName=fcnNames{i};

        fcnPath=getClassFilePath(fcnName,structClass);
        fcnStruct=loadJSON(fcnPath);
        if isfield(fcnStruct,'BackwardLinks_Variable') % Input variables
            inputVars=fcnStruct.BackwardLinks_Variable;
        else
            inputVars={};
        end
        if isfield(fcnStruct,'ForwardLinks_Variable') % Output variables.
            outputVars=fcnStruct.ForwardLinks_Variable;
        else
            outputVars={};
        end

        allInputVars{i}=inputVars;
        allOutputVars{i}=outputVars;

        % Need to recursively investigate the dependencies for each variable in each function.

    end
end