function []=logsheetPathFieldValueChanged(src,dontRead)

%% PURPOSE: UPDATE THE LOGSHEET PATH FIELD VALUE, AND SAVE A COPY OF THE XLSX FILE TO MAT FILE
% Inputs:
% dontRead: If present (likely 0), do not read the logsheet file. Just
% opening the GUI.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

logsheetPath=handles.Import.logsheetPathField.Value;

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

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

handles.Import.logsheetPathField.Value=logsheetPath;

setappdata(fig,'logsheetPath',logsheetPath);

macAddress=getComputerID();

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file
% NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath=logsheetPath; % Store the computer-specific logsheet path to the struct

% Convert the logsheet to .mat file format.
[logsheetFolder,name,ext]=fileparts(logsheetPath);
logsheetPathMAT=[logsheetFolder slash name '.mat'];

%% Create MAT file from logsheet
% Opening: dontRead=0, logsheetPathMAT may or may not exist
% Changing: dontRead does not exist, logsheetPathMAT may or may not exist
if ~(exist('dontRead','var') && exist(logsheetPathMAT,'file')==2) % Don't do MAT file from logsheet

    % IN THE FUTURE, DO OTHER EXTENSIONS TOO (CSV, OTHERS?)
    if contains(ext,'xls')
        [~,~,logsheetVar]=xlsread(logsheetPath,1);
    end

    % If numHeaderRows>=0 and subject ID codename column header and target trial ID column headers are found in the first row of the logsheet,
    % then ensure that every entry in the column is a valid MATLAB variable name before saving to .mat file format.
    subjIDColHeader=NonFcnSettingsStruct.Import.SubjectIDColHeader;
    targetTrialIDColHeader=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;
    numHeaderRows=NonFcnSettingsStruct.Import.NumHeaderRows;

    if all(ismember({subjIDColHeader,targetTrialIDColHeader},logsheetVar(1,:))) && numHeaderRows>=0 % All logsheet-related fields have been properly filled out, except data type-specific ones (because they're used for read only)
        subjCodenames=logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),subjIDColHeader));
        targetTrialIDs=logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),targetTrialIDColHeader));
        for i=1:length(subjCodenames)
            if ~isvarname(subjCodenames{i}) && ~isempty(subjCodenames{i})
                subjCodenames{i}=genvarname(subjCodenames{i});
            end
            if ~isvarname(targetTrialIDs{i}) && ~isempty(targetTrialIDs{i})
                targetTrialIDs{i}=genvarname(targetTrialIDs{i});
            end
        end
        logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),subjIDColHeader))=subjCodenames;
        logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),targetTrialIDColHeader))=targetTrialIDs;
    end

    save(logsheetPathMAT,'logsheetVar','-v6'); % Save the MAT file version of the logsheet.

    NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT=logsheetPathMAT;    

    resetProjectAccess_Visibility(fig,4);

elseif exist(logsheetPathMAT,'file')==2
    load(logsheetPathMAT,'logsheetVar');
else
    disp(['Logsheet MAT file missing from: ' logsheetPathMAT]);
    return;
end

%% Initialize the logsheet variables in the MAT file
% Fill in the logsheet list box, and save default values for each
% variable's attributes
delete(handles.Import.logVarsUITree.Children);
headerNames=logsheetVar(1,:);
headerNamesVars=genvarname(headerNames);
[~,idx]=sort(upper(headerNamesVars));
headerNamesVars=headerNamesVars(idx);
headerNames=headerNames(idx);
for i=1:size(logsheetVar,2)

    headerName=headerNames{i};
    headerNameVar=headerNamesVars{i};

    a=uitreenode(handles.Import.logVarsUITree,'Text',headerName,'Tag',headerName);

    if ~(isfield(NonFcnSettingsStruct.Import,'LogsheetVars') && isfield(NonFcnSettingsStruct.Import.LogsheetVars,headerNameVar))
        NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType='';
        NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject='';
%         NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).VarName=headerNameVar;
    end

    if i==1
        handles.Import.logVarsUITree.SelectedNodes=a;
    end

end

handles.Import.dataTypeDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType;
handles.Import.trialSubjectDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject;

% If there's no Digraph in the projectSettingsMATPath, make one and plot
% it.
% Fill in processing map figure
projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

if ismember('Digraph',projectSettingsVarNames)
    load(projectSettingsMATPath,'Digraph');    
else
    Digraph=digraph;
    Digraph=addnode(Digraph,1);
    Digraph.Nodes.FunctionNames={'Logsheet'};
    Digraph.Nodes.Descriptions={{''}};
    Digraph.Nodes.InputVariableNames={{''}}; % Name in file
    Digraph.Nodes.OutputVariableNames={{''}}; % Name in file
    Digraph.Nodes.Coordinates=[0 0];  
    Digraph.Nodes.SplitNames={{'Default'}};

    save(projectSettingsMATPath,'Digraph','-append');
end

plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames);

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append'); % Save the struct back to file.