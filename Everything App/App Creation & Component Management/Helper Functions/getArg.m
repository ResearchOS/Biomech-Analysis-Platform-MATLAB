function [varargout]=getArg(inputNamesInCode,subName,trialName,repNum)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% FIRST LOOKS THROUGH VARS EXISTING IN THE WORKSPACE. IF NOT FOUND THERE, SEARCHES IN THE CORRESPONDING MAT FILE. IF NOT FOUND THERE, THROWS ERROR.
% Inputs:
% inputNamesinCode: The names of the input arguments. Spelling must match the input arguments function (cell array of chars)
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)
% repNum: The repetition number, if accessing trial data. If subject or project level data, not inputted (double)

% Outputs:
% argIn: The argument to pass in to the processing function

slash=filesep;

if exist('inputNamesInCode','var')~=1
    inputNamesInCode='';
end
if exist('trialName','var')~=1
    trialName='';
end
if exist('repNum','var')~=1
    repNum='';
end
if exist('subName','var')~=1
    subName='';
end

if nargin>0 && ~isempty(inputname(1)) % Ensure that the getArg is specified as a cell array in-line, and not provided as a variable containing a cell array
    disp('Input names must be a hard-coded cell array or character vector, not a variable!');
    return;
end

if ~iscell(inputNamesInCode)
    inputNamesInCode={inputNamesInCode}; % There's only one input argument, so make it a cell if not already.
end

if length(inputNamesInCode)~=length(unique(inputNamesInCode))
    beep;
    disp('Argument names in code must be unique!');
    return;
end

try
    fig=evalin('base','gui;');
catch
    fig='';
end
isRunCode=0;
if isempty(fig)
    try
        fig=evalin('base','runCodeHiddenGUI;');
    catch
        fig='';
    end
    isRunCode=1;
    if isempty(fig)
        disp('Missing the GUI!');
        return;
    end
end

varargout=cell(length(inputNamesInCode),1); % Initialize the output variables.

projectName=getappdata(fig,'projectName');
handles=getappdata(fig,'handles');
if isempty(handles)
    tabName='Process';
else
    tabName=handles.Tabs.tabGroup1.SelectedTab.Title;
end

if ~isempty(repNum) && ~isempty(trialName) % Trial level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
elseif ~isempty(subName) % Subject level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
else % Project level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];
end

if isequal(tabName,'Process')

    nodeRow=getappdata(fig,'nodeRow');        

    if isRunCode==0
        Digraph=getappdata(fig,'Digraph');
        VariableNamesList=getappdata(fig,'VariableNamesList');
        if isempty(Digraph) || isempty(VariableNamesList)
            load(getappdata(fig,'projectSettingsMATPath'),'Digraph','VariableNamesList');
        end
    else
        try
            VariableNamesList=evalin('base','VariableNamesList;');
            Digraph=evalin('base','Digraph;');
        catch
            disp('Missing settings variables from the base workspace!');
            return;
        end
    end

    splitName=getappdata(fig,'splitName');
    splitCode=getappdata(fig,'splitCode');

    %% All input vars
    % The idx/subset of the variables currently being accessed
    [~,~,currVarsIdx]=intersect(inputNamesInCode,Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode]),'stable');
    try
        assert(isequal(Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])(currVarsIdx)',inputNamesInCode));
    catch
        a=inputNamesInCode(~ismember(inputNamesInCode,Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])(currVarsIdx)'));
        disp(a);
        error('Check your input variable names in code!');
    end
    % [~,a,currVarsIdx]=intersect(inputNamesInCode,Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode]),'stable');
    % The GUI names of the variables currently being accessed (in the order of the inputNamesInCode).
    inputVarNamesInGUI_Split=Digraph.Nodes.InputVariableNames{nodeRow}.([splitName '_' splitCode])(currVarsIdx);
    inputVarNamesInGUI=cell(size(inputVarNamesInGUI_Split));
    varSplits=cell(size(inputVarNamesInGUI));
    for i=1:length(inputVarNamesInGUI_Split)
        inputVarNamesInGUI{i}=inputVarNamesInGUI_Split{i}(1:end-6); % Remove the split code
        varSplits{i}=inputVarNamesInGUI_Split{i}(end-3:end-1); % In the order of the inputNamesInCode
    end

    [~,~,varRowsIdxNums]=intersect(inputVarNamesInGUI,VariableNamesList.GUINames,'stable'); % The rows in the VariableNamesList matrix of the variables currently being accessed
    assert(isequal(inputVarNamesInGUI,VariableNamesList.GUINames(varRowsIdxNums)));
    saveNames=VariableNamesList.SaveNames(varRowsIdxNums); % The save names of all vars in inputNamesInCode (in the same order)    

    %% Hard-coded variables
    hardCodedStatus=VariableNamesList.IsHardCoded(varRowsIdxNums);
    hardCodedIdxNums=find(cellfun(@isequal,hardCodedStatus,repmat({1},length(hardCodedStatus),1))==1); % The idx of hard-coded vars (in the order of the inputNamesInCode)
    hardCodedSaveNames=saveNames(hardCodedIdxNums);

    if ~isempty(hardCodedIdxNums)
        folderName=[getappdata(fig,'codePath') 'Hard-Coded Variables'];
        oldPath=cd(folderName);

        for i=1:length(hardCodedSaveNames)

            % Get .m full file path and ensure that it exists
            varName=hardCodedSaveNames{i};
            splitCodeVar=varSplits{hardCodedIdxNums(i)};
            varargout{hardCodedIdxNums(i)}=feval([varName '_' splitCodeVar]);

        end
        cd(oldPath);
    end

    %% Dynamic variables
    dynamicIdxNums=find(cellfun(@isequal,hardCodedStatus,repmat({0},length(hardCodedStatus),1))==1);
    if isempty(dynamicIdxNums)
        return;
    end
    dynamicSaveNames=saveNames(dynamicIdxNums);

    for i=1:length(dynamicSaveNames)
        splitCodeVar=varSplits{dynamicIdxNums(i)};
        dynamicSaveNames{i}=[dynamicSaveNames{i} '_' splitCodeVar];
    end

    try
        S=load(matFilePath,'-mat',dynamicSaveNames{:});
%         S=load(matFilePath,dynamicSaveNames{:});
%         load(matFilePath,'Mocap_Marker_Data_001');
    catch
        if exist(matFilePath,'file')~=2
            disp(['No saved file found at: ' matFilePath]);
            return;
        end

        fileVarNames=whos('-file',matFilePath);
        fileVarNames={fileVarNames.name};

        if ~all(ismember(dynamicSaveNames,fileVarNames))
            disp('Missing variables in mat file!'); % Specify which variables
            return;
        end
    end

    for i=1:length(dynamicSaveNames)
        varargout{dynamicIdxNums(i)}=S.(dynamicSaveNames{i}); % This requires copying variables, which is inherently slow. Faster way?
    end

elseif isequal(tabName,'Plot')
    if isRunCode==0
        Plotting=getappdata(fig,'Plotting');
        VariableNamesList=getappdata(fig,'VariableNamesList');
        if isempty(Plotting) || isempty(VariableNamesList)
            load(getappdata(fig,'projectSettingsMATPath'),'Plotting','VariableNamesList');
        end
    else
        try
            VariableNamesList=evalin('base','VariableNamesList;');
            Plotting=evalin('base','Plotting;');
        catch
            disp('Missing settings variables from the base workspace!');
            return;
        end
    end
    plotName=getappdata(fig,'plotName');
    compName=getappdata(fig,'compName');
    letter=getappdata(fig,'letter');

    if ~isfield(Plotting.Plots.(plotName).(compName).(letter).Variables,'NamesInCode')
        disp('Must assign variables to component first!');
        return;
    end

    if nargin==0
        vars=Plotting.Plots.(plotName).(compName).(letter).Variables;
        varargout{1}=vars.HardCodedValue;
        return;
    end

    [~,~,currVarsIdx]=intersect(inputNamesInCode,Plotting.Plots.(plotName).(compName).(letter).Variables.NamesInCode,'stable');
    try
        assert(isequal(Plotting.Plots.(plotName).(compName).(letter).Variables.NamesInCode(currVarsIdx)',inputNamesInCode));
    catch
        a=inputNamesInCode(~ismember(inputNamesInCode,Plotting.Plots.(plotName).(compName).(letter).Variables.NamesInCode(currVarsIdx)'));
        disp(a);
        error('Check your input variable names in code!');
    end

    namesSuffix=Plotting.Plots.(plotName).(compName).(letter).Variables.Names(currVarsIdx);
    names=cell(size(namesSuffix));
    varSplits=cell(size(names));
    for i=1:length(namesSuffix)
        names{i}=namesSuffix{i}(1:end-6);
        varSplits{i}=namesSuffix{i}(end-3:end-1);
    end

    [~,~,varRowsIdxNums]=intersect(names,VariableNamesList.GUINames,'stable'); % The rows in the VariableNamesList matrix of the variables currently being accessed
    assert(isequal(names,VariableNamesList.GUINames(varRowsIdxNums)));
    saveNames=VariableNamesList.SaveNames(varRowsIdxNums); % The save names of all vars in inputNamesInCode (in the same order)    

    %% Hard-coded variables
    hardCodedStatus=VariableNamesList.IsHardCoded(varRowsIdxNums);
    hardCodedIdxNums=find(cellfun(@isequal,hardCodedStatus,repmat({1},length(hardCodedStatus),1))==1); % The idx of hard-coded vars (in the order of the inputNamesInCode)
    hardCodedSaveNames=saveNames(hardCodedIdxNums);

    if ~isempty(hardCodedIdxNums)
        folderName=[getappdata(fig,'codePath') 'Hard-Coded Variables'];
        oldPath=cd(folderName);

        for i=1:length(hardCodedSaveNames)

            % Get .m full file path and ensure that it exists
            varName=hardCodedSaveNames{i};
            splitCodeVar=varSplits{hardCodedIdxNums(i)};
            varargout{hardCodedIdxNums(i)}=feval([varName '_' splitCodeVar]);

        end
        cd(oldPath);
    end

    %% Dynamic variables
    dynamicIdxNums=find(cellfun(@isequal,hardCodedStatus,repmat({0},length(hardCodedStatus),1))==1);
    if isempty(dynamicIdxNums)
        return;
    end
    dynamicSaveNames=saveNames(dynamicIdxNums);

    for i=1:length(dynamicSaveNames)
        splitCodeVar=varSplits{dynamicIdxNums(i)};
        dynamicSaveNames{i}=[dynamicSaveNames{i} '_' splitCodeVar];
    end

    try
        S=load(matFilePath,'-mat',dynamicSaveNames{:});
    catch
        if exist(matFilePath,'file')~=2
            disp(['No saved file found at: ' matFilePath]);
            return;
        end

        fileVarNames=whos('-file',matFilePath);
        fileVarNames={fileVarNames.name};

        if ~all(ismember(dynamicSaveNames,fileVarNames))
            disp('Missing variables in mat file!'); % Specify which variables
            return;
        end
    end

    subVars=Plotting.Plots.(plotName).(compName).(letter).Variables.Subvars;

    for i=1:length(dynamicSaveNames)
        if ~isempty(subVars{i})
            varargout{dynamicIdxNums(i)}=eval(['S.(dynamicSaveNames{i})' subVars{i} ';']); % This requires copying variables, which is inherently slow. Faster way?
            dims=size(varargout{dynamicIdxNums(i)});
            if any(dims==1) && length(dims)>2
                varargout{dynamicIdxNums(i)}=squeeze(varargout{dynamicIdxNums(i)}); % Remove unnecessary dimensions, if needed.
            end
        else
            varargout{dynamicIdxNums(i)}=S.(dynamicSaveNames{i});
        end
    end

elseif isequal(tabName,'Stats')
    if isRunCode==0
        Stats=getappdata(fig,'Stats');
        VariableNamesList=getappdata(fig,'VariableNamesList');
        if isempty(Stats) || isempty(VariableNamesList)
            load(getappdata(fig,'projectSettingsMATPath'),'Stats','VariableNamesList');
        end
    else
        try
            VariableNamesList=evalin('base','VariableNamesList;');
            Stats=evalin('base','Stats;');
        catch
            disp('Missing settings variables from the base workspace!');
            return;
        end
    end
    tableName=getappdata(fig,'tableName');
    fcnName=getappdata(fig,'fcnName');
    fcnIdx=getappdata(fig,'fcnIdx');
%     fcnNameStruct=fcnName(1:end-6);

    if ~isfield(Stats.Tables.(tableName).DataColumns(fcnIdx),'NamesInCode')
        error('Must assign variables to table first!');
    end

%     if nargin==0
%         vars=Stats.Tables.(tableName).(fcnName).(letter).Variables;
%         varargout{1}=vars.HardCodedValue;
%         return;
%     end

    [~,~,currVarsIdx]=intersect(inputNamesInCode,Stats.Tables.(tableName).DataColumns(fcnIdx).NamesInCode,'stable');
    try
        assert(isequal(Stats.Tables.(tableName).DataColumns(fcnIdx).NamesInCode(currVarsIdx)',inputNamesInCode));
    catch
        a=inputNamesInCode(~ismember(inputNamesInCode,Stats.Tables.(tableName).DataColumns(fcnIdx).NamesInCode(currVarsIdx)'));
        disp(a);
        error('Check your input variable names in code!');
    end

    namesSuffix=Stats.Tables.(tableName).DataColumns(fcnIdx).GUINames(currVarsIdx);
    names=cell(size(namesSuffix));
    varSplits=cell(size(names));
    for i=1:length(namesSuffix)
        names{i}=namesSuffix{i}(1:end-6);
        varSplits{i}=namesSuffix{i}(end-3:end-1);
    end

    [~,~,varRowsIdxNums]=intersect(names,VariableNamesList.GUINames,'stable'); % The rows in the VariableNamesList matrix of the variables currently being accessed
    assert(isequal(names,VariableNamesList.GUINames(varRowsIdxNums)));
    saveNames=VariableNamesList.SaveNames(varRowsIdxNums); % The save names of all vars in inputNamesInCode (in the same order)    

    %% Hard-coded variables
    hardCodedStatus=VariableNamesList.IsHardCoded(varRowsIdxNums);
    hardCodedIdxNums=find(cellfun(@isequal,hardCodedStatus,repmat({1},length(hardCodedStatus),1))==1); % The idx of hard-coded vars (in the order of the inputNamesInCode)
    hardCodedSaveNames=saveNames(hardCodedIdxNums);

    if ~isempty(hardCodedIdxNums)
        folderName=[getappdata(fig,'codePath') 'Hard-Coded Variables'];
        oldPath=cd(folderName);

        for i=1:length(hardCodedSaveNames)

            % Get .m full file path and ensure that it exists
            varName=hardCodedSaveNames{i};
            splitCodeVar=varSplits{hardCodedIdxNums(i)};
            varargout{hardCodedIdxNums(i)}=feval([varName '_' splitCodeVar]);

        end
        cd(oldPath);
    end

    %% Dynamic variables
    dynamicIdxNums=find(cellfun(@isequal,hardCodedStatus,repmat({0},length(hardCodedStatus),1))==1);
    if isempty(dynamicIdxNums)
        return;
    end
    dynamicSaveNames=saveNames(dynamicIdxNums);

    for i=1:length(dynamicSaveNames)
        splitCodeVar=varSplits{dynamicIdxNums(i)};
        dynamicSaveNames{i}=[dynamicSaveNames{i} '_' splitCodeVar];
    end

    try
        S=load(matFilePath,'-mat',dynamicSaveNames{:});
    catch
        if exist(matFilePath,'file')~=2
            disp(['No saved file found at: ' matFilePath]);
            return;
        end

        fileVarNames=whos('-file',matFilePath);
        fileVarNames={fileVarNames.name};

        if ~all(ismember(dynamicSaveNames,fileVarNames))
            disp('Missing variables in mat file!'); % Specify which variables
            return;
        end
    end

    subVars=Stats.Tables.(tableName).DataColumns(fcnIdx).Subvars;

    for i=1:length(dynamicSaveNames)
        hasSubvar=false;
        if ~isempty(subVars{i})
            hasSubvar=true;
            try
                varargout{dynamicIdxNums(i)}=eval(['S.(dynamicSaveNames{i})' subVars{i} ';']); % This requires copying variables, which is inherently slow. Faster way?
            catch
                hasSubvar=false; % In case this is an anomaly trial, still load the data (most likely NaN).
                disp(['No subvariable as specified: ' subName ' ' trialName ' ' num2str(repNum) ' ' dynamicSaveNames{i}])
            end
            dims=size(varargout{dynamicIdxNums(i)});
            if any(dims==1) && length(dims)>2
                varargout{dynamicIdxNums(i)}=squeeze(varargout{dynamicIdxNums(i)}); % Remove unnecessary dimensions, if needed.
            end
        end
        if ~hasSubvar
            varargout{dynamicIdxNums(i)}=S.(dynamicSaveNames{i});
        end
    end


end