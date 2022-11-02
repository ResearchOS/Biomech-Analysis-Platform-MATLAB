function []=logsheetPathFieldValueChanged(src,logsheetPath)

%% PURPOSE: UPDATE THE LOGSHEET PATH FIELD VALUE, AND SAVE A COPY OF THE XLSX FILE TO MAT FILE
% Inputs:
% when the logsheetPath is present AND using the GUI, that means not to
% re-read the Excel file. If the logsheet path is not present OR not using
% the GUI, then re-read the Excel file.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');
macAddress=getComputerID();

if exist('logsheetPath','var')~=1
    logsheetPath=handles.Import.logsheetPathField.Value;    
    readLogsheet=0; % Indicates that the logsheet should just be read, because I entered it in the textbox.
    runLog=true;
else
    if ~isempty(handles)
        handles.Import.logsheetPathField.Value=logsheetPath;
    end
    readLogsheet=1;
    runLog=false;
end

if isempty(logsheetPath) || isequal(logsheetPath,'Logsheet Path (ends in .xlsx)')
    setappdata(fig,'logsheetPath','');
    resetProjectAccess_Visibility(fig,3);
    return;
end

if exist(logsheetPath,'file')~=2
    warning(['Incorrect logsheet path: ' logsheetPath]);
    resetProjectAccess_Visibility(fig,3);
    return;
end

NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath=logsheetPath; % Store the computer-specific logsheet path to the struct

slash=filesep;

if ~isempty(handles)
    handles.Import.logsheetPathField.Value=logsheetPath; % GUI only
end

setappdata(fig,'logsheetPath',logsheetPath);

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

% projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);
% projectVarNames=whos('-file',projectSettingsMATPath);
% projectVarNames={projectVarNames.name};

% if ismember('VariableNamesList',projectVarNames)
%     load(projectSettingsMATPath,'NonFcnSettingsStruct','VariableNamesList'); % Load the non-fcn settings struct from the project settings MAT file
% VariableNamesList=getappdata(fig,'VariableNamesList');
% else
%     load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file    
% end
% NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

% Convert the logsheet to .mat file format.
[logsheetFolder,name,ext]=fileparts(logsheetPath);
logsheetPathMAT=[logsheetFolder slash name '.mat'];

%% Create MAT file from logsheet
% Opening: dontRead=0, logsheetPathMAT may or may not exist
% Changing: dontRead does not exist, logsheetPathMAT may or may not exist
if readLogsheet==1 % Don't do MAT file from logsheet

    % If numHeaderRows>=0 and subject ID codename column header and target trial ID column headers are found in the first row of the logsheet,
    % then ensure that every entry in the column is a valid MATLAB variable name before saving to .mat file format.
    if isfield(NonFcnSettingsStruct.Import,'SubjectIDColHeader')
        subjIDColHeader=NonFcnSettingsStruct.Import.SubjectIDColHeader;
    else
        return;
    end
    if isfield(NonFcnSettingsStruct.Import,'TargetTrialIDColHeader')
        targetTrialIDColHeader=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;
    else
        return;
    end
    if isfield(NonFcnSettingsStruct.Import,'NumHeaderRows')
        numHeaderRows=NonFcnSettingsStruct.Import.NumHeaderRows;
    else
        return;
    end

    % IN THE FUTURE, DO OTHER EXTENSIONS TOO (CSV, OTHERS?)
    if contains(ext,'xls')
        [~,~,logVar]=xlsread(logsheetPath,1);
    end    

    if all(ismember({subjIDColHeader,targetTrialIDColHeader},logVar(1,:))) && numHeaderRows>=0 % All logsheet-related fields have been properly filled out, except data type-specific ones (because they're used for read only)
        subjCodenames=logVar(numHeaderRows+1:end,ismember(logVar(1,:),subjIDColHeader));
        targetTrialIDs=logVar(numHeaderRows+1:end,ismember(logVar(1,:),targetTrialIDColHeader));
        for i=1:length(subjCodenames)
            if ~isvarname(subjCodenames{i}) && ~isempty(subjCodenames{i})
                subjCodenames{i}=genvarname(subjCodenames{i});
            end
            if ~isvarname(targetTrialIDs{i}) && ~isempty(targetTrialIDs{i})
                if ~isnan(targetTrialIDs{i})
                    targetTrialIDs{i}=genvarname(targetTrialIDs{i});
                else
                    targetTrialIDs{i}='';
                end
            end
        end
        logVar(numHeaderRows+1:end,ismember(logVar(1,:),subjIDColHeader))=subjCodenames;
        logVar(numHeaderRows+1:end,ismember(logVar(1,:),targetTrialIDColHeader))=targetTrialIDs;
    end

    save(logsheetPathMAT,'logVar','-v6'); % Save the MAT file version of the logsheet.
    if isempty(handles)
        assignin('base','logVar',logVar);
    end

    NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT=logsheetPathMAT;    

    if ~isempty(handles)
        resetProjectAccess_Visibility(fig,4);
    end

elseif exist(logsheetPathMAT,'file')==2
    load(logsheetPathMAT,'logVar');
else
    disp(['Logsheet MAT file missing from: ' logsheetPathMAT]);
    return;
end

setappdata(fig,'logsheetPathMAT',logsheetPathMAT);

%% Initialize the logsheet variables in the MAT file
% Fill in the logsheet list box, and save default values for each
% variable's attributes
if ~isempty(handles)
    delete(handles.Import.logVarsUITree.Children);
end
headerNames=logVar(1,:);
headerNamesVars=genvarname(headerNames);
[~,idx]=sort(upper(headerNamesVars));
headerNamesVars=headerNamesVars(idx);
headerNames=headerNames(idx);
for i=1:size(logVar,2)

    headerName=headerNames{i};
    headerNameVar=headerNamesVars{i};

    if ~isempty(handles)
        a=uitreenode(handles.Import.logVarsUITree,'Text',headerName,'Tag',headerName);
    end

    if ~(isfield(NonFcnSettingsStruct.Import,'LogsheetVars') && isfield(NonFcnSettingsStruct.Import.LogsheetVars,headerNameVar))
        NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType='';
        NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject='';
%         NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).VarName=headerNameVar;
    end

    if ~isempty(handles)
        if i==1
            handles.Import.logVarsUITree.SelectedNodes=a;
            handles.Import.dataTypeDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType;
            handles.Import.trialSubjectDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject;
        end
    end

end

% If there's no Digraph in the projectSettingsMATPath, make one and plot
% it.
% Fill in processing map figure
% projectSettingsVars=whos('-file',projectSettingsMATPath);
% projectSettingsVarNames={projectSettingsVars.name};

% if ismember('Digraph',projectSettingsVarNames)
%     load(projectSettingsMATPath,'Digraph');    
Digraph=getappdata(fig,'Digraph');
if isempty(Digraph)
    Digraph=digraph;
    Digraph=addnode(Digraph,1);
    Digraph.Nodes.FunctionNames={'Logsheet'};
    Digraph.Nodes.Descriptions={{''}};
    Digraph.Nodes.InputVariableNames{1}=''; % Name in GUI
    Digraph.Nodes.OutputVariableNames{1}=''; % Name in GUI
    Digraph.Nodes.Coordinates=[0 0];
    %     Digraph.Nodes.SplitCodes={{'001'}};
    Digraph.Nodes.NodeNumber=1;
    Digraph.Nodes.SpecifyTrials={''};
    Digraph.Nodes.IsImport=false;
    Digraph.Nodes.InputVariableNamesInCode{1}=''; % Name in file/code
    Digraph.Nodes.OutputVariableNamesInCode{1}=''; % Name in file/code
%     Digraph.Nodes.RunOrder{1}=[];

    splitName={'Default'};
    splitCode='001';
    maxSplitCode=splitCode;
    NonFcnSettingsStruct.Process.Splits.SubSplitNames.(splitName{1}).Code=splitCode;
    NonFcnSettingsStruct.Process.Splits.SubSplitNames.(splitName{1}).Name=splitName;
    NonFcnSettingsStruct.Process.Splits.SubSplitNames.(splitName{1}).Color=[0 0.4470 0.7410]; % MATLAB R2021b first color in default color order

    save(projectSettingsMATPath,'maxSplitCode','-append');
    setappdata(fig,'Digraph',Digraph);
    setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
end

%% Add the splits UI tree nodes on the Process tab
if ~isempty(handles)
    delete(handles.Process.splitsUITree.Children);
    h=findobj(handles.Process.mapFigure,'Type','GraphPlot');
    delete(h);
    getSplitNames(NonFcnSettingsStruct.Process.Splits,[],handles.Process.splitsUITree);

    if ~isempty(Digraph.Edges)
        h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.4470 0.7410],'Interpreter','none');
        h.EdgeColor=Digraph.Edges.Color;
        splitsUITreeSelectionChanged(fig,'Default (001)');
    else
        plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.4470 0.7410],'Interpreter','none');
    end
end

% save(projectSettingsMATPath,'NonFcnSettingsStruct','-append'); % Save the struct back to file.
setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
if ~isempty(handles)
    resetProjectAccess_Visibility(fig,4);
end

if runLog
    desc='Update the logsheet path';
    updateLog(fig,desc,logsheetPath);
end