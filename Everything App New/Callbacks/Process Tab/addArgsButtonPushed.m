function []=addArgsButtonPushed(src,event)

%% PURPOSE:

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

number=str2double(text(idx+length(varType)+1:commaIdx-1));

if isnan(number)
    disp('Invalid number. Should be the first argument!');
    return;
end

% Check if that number has already been used.
namePS=handles.Process.groupUITree.SelectedNodes.Text;
fullPathPS=getClassFilePath_PS(namePS, 'Process', fig);
psStruct=loadJSON(fullPathPS);

namePI=getPITextFromPS(namePS);
fullPathPI=getClassFilePath(namePI, 'Process', fig);
piStruct=loadJSON(fullPathPI);

if isequal(varType,'getArg')
    checkArgs=piStruct.InputVariablesNamesInCode;
elseif isequal(varType,'setArg')
    checkArgs=piStruct.OutputVariablesNamesInCode;
end
for i=1:length(checkArgs)
    if isequal(checkArgs{i}{1},number)
        disp('This number is already taken!');
        return;
    end
end

% c.
if isequal(varType,'getArg')
    equalsIdx=strfind(text,'=');
    argsText=text(2:equalsIdx-2);
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

argsEmpty=[{number}; cell(size(argsSplit))']; % To initialize the project-specific args.
argsSplit=[{number}; argsSplit']; % Column vector for JSON format.

% 3. Store the info in the PI process struct.
if isequal(varType,'getArg')
    piStruct.InputVariablesNamesInCode=[piStruct.InputVariablesNamesInCode; {argsSplit}];
    psStruct.InputVariables=[psStruct.InputVariables; {argsEmpty}];
elseif isequal(varType,'setArg')
    piStruct.OutputVariablesNamesInCode=[piStruct.OutputVariablesNamesInCode; {argsSplit}];
    psStruct.OutputVariables=[psStruct.OutputVariables; {argsEmpty}];
end

writeJSON(fullPathPI, piStruct);
writeJSON(fullPathPS, psStruct);

% 4. Add the args to the UI tree
fillCurrentFunctionUITree(fig);