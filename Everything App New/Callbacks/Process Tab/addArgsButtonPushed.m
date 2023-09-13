function []=addArgsButtonPushed(src,event)

%% PURPOSE:

disp('Adding arguments!');
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% 1. Prompt the user to paste the getArg/setArg line.
text=inputdlg('Paste the entire getArg or setArg line');

if isempty(text)
    return;
end

text=text{1};

text=strrep(text,' ',''); % Remove all spaces
text=strrep(text,'...',''); % Remove ... for multi-line statements

if isempty(text)
    return;
end

% Remove comments
commentIdx=strfind(text,'%');

if ~isempty(commentIdx)
    text=text(1:commentIdx-1);
end

% 2. Parse the input to determine:
% a. getArg or setArg
% b. Number (ID)
% c. The names in code of the arguments

% a.
if contains(text,'getArg')
    varType='getArg';
elseif contains(text,'setArg')
    varType='setArg';
else
    disp('The copied text must include getArg or setArg!');
    return;
end

% b.
idx=strfind(text,varType);
allCommaIdx=strfind(text,',');
commaIdx=allCommaIdx(allCommaIdx>=idx);

if isempty(allCommaIdx) % Project level, no commas
    openParensIdx=strfind(text,'(');
    closeParensIdx=strfind(text,')');
    number=str2double(text(openParensIdx+1:closeParensIdx-1));
else
    number=str2double(text(idx+length(varType)+1:commaIdx-1));
end

if isnan(number)
    disp('Invalid number. Should be the first argument!');
    return;
end

fcnNode = handles.Process.groupUITree.SelectedNodes;
fcnUUID = fcnNode.NodeData.UUID;
% fcnStruct = loadJSON(fcnUUID);

[type, abstractID, instanceID] = deText(fcnUUID);
fcnAbstractUUID = genUUID(type, abstractID);
abstractFcnStruct = loadJSON(fcnAbstractUUID);

if isequal(varType,'getArg')
    checkArgsAbstract=abstractFcnStruct.InputVariablesNamesInCode;    
elseif isequal(varType,'setArg')
    checkArgsAbstract=abstractFcnStruct.OutputVariablesNamesInCode;    
end

% The index to place the new arguments in the abstract function object.
absIdx = length(checkArgsAbstract)+1;
for i=1:length(checkArgsAbstract)
    if isequal(checkArgsAbstract{i}{1},number)
        absIdx = i;
        break;
    end
end

% c.
if isequal(varType,'getArg')
    equalsIdx=strfind(text,'=');
    if isequal([text(1) text(equalsIdx-1)],'[]')
        argsText=text(2:equalsIdx-2);
    else
        argsText=text(1:equalsIdx-1);
    end
    argsSplit=strsplit(argsText,',');
elseif isequal(varType,'setArg')
    argsText=text(allCommaIdx(1)+1:end-2);
    argsSplit=strsplit(argsText,',');

    if length(argsSplit)<4
        disp('Need to specify subject/trial/rep level. Specify as empty if not using that level');
        return;
    end

    argsSplit=argsSplit(4:end);
end

subVarsEmpty=cell(size(argsSplit));
for i=1:length(subVarsEmpty)
    subVarsEmpty{i}='';
end

argsSplit=[{number}; argsSplit']; % Column vector for JSON format.

% 3. Store the info in the PI process struct.
if isequal(varType,'getArg')
    if absIdx<=length(abstractFcnStruct.InputVariablesNamesInCode)
        abstractFcnStruct.InputVariablesNamesInCode(absIdx)={argsSplit};
    else
        abstractFcnStruct.InputVariablesNamesInCode = [abstractFcnStruct.InputVariablesNamesInCode; {argsSplit}];
    end
elseif isequal(varType,'setArg')
    if absIdx<=length(abstractFcnStruct.OutputVariablesNamesInCode)
        abstractFcnStruct.OutputVariablesNamesInCode(absIdx)={argsSplit};
    else
        abstractFcnStruct.OutputVariablesNamesInCode = [abstractFcnStruct.OutputVariablesNamesInCode; {argsSplit}];
    end
end

writeJSON(abstractFcnStruct);

% 4. Add the args to the UI tree
fillCurrentFunctionUITree(fig);
disp('Finished adding arguments!');