function []=logsheetPathFieldValueChanged(src,logsheetPath)

%% PURPOSE: UPDATE THE LOGSHEET PATH FIELD VALUE, AND SAVE A COPY OF THE XLSX FILE TO MAT FILE
% Inputs:
% dontRead: If present (likely 0), do not read the logsheet file. Just
% opening the GUI.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

if exist('logsheetPath','var')~=1
    logsheetPath=handles.Import.logsheetPathField.Value;
    runLog=true;
else
    handles.Import.logsheetPathField.Value=logsheetPath;
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

slash=filesep;

handles.Import.logsheetPathField.Value=logsheetPath;

setappdata(fig,'logsheetPath',logsheetPath);

macAddress=getComputerID();

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);
projectVarNames=whos('-file',projectSettingsMATPath);
projectVarNames={projectVarNames.name};

if ismember('VariableNamesList',projectVarNames)
%     load(projectSettingsMATPath,'NonFcnSettingsStruct','VariableNamesList'); % Load the non-fcn settings struct from the project settings MAT file
    VariableNamesList=getappdata(fig,'VariableNamesList');
else
%     load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file    
end
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');
% NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath=logsheetPath; % Store the computer-specific logsheet path to the struct

% Convert the logsheet to .mat file format.
[logsheetFolder,name,ext]=fileparts(logsheetPath);
logsheetPathMAT=[logsheetFolder slash name '.mat'];

%% Create MAT file from logsheet
% Opening: dontRead=0, logsheetPathMAT may or may not exist
% Changing: dontRead does not exist, logsheetPathMAT may or may not exist
if getappdata(fig,'switchingProjects')==1 % Don't do MAT file from logsheet

    % IN THE FUTURE, DO OTHER EXTENSIONS TOO (CSV, OTHERS?)
    if contains(ext,'xls')
        [~,~,logVar]=xlsread(logsheetPath,1);
    end

    % If numHeaderRows>=0 and subject ID codename column header and target trial ID column headers are found in the first row of the logsheet,
    % then ensure that every entry in the column is a valid MATLAB variable name before saving to .mat file format.
    subjIDColHeader=NonFcnSettingsStruct.Import.SubjectIDColHeader;
    targetTrialIDColHeader=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;
    numHeaderRows=NonFcnSettingsStruct.Import.NumHeaderRows;

    if all(ismember({subjIDColHeader,targetTrialIDColHeader},logVar(1,:))) && numHeaderRows>=0 % All logsheet-related fields have been properly filled out, except data type-specific ones (because they're used for read only)
        subjCodenames=logVar(numHeaderRows+1:end,ismember(logVar(1,:),subjIDColHeader));
        targetTrialIDs=logVar(numHeaderRows+1:end,ismember(logVar(1,:),targetTrialIDColHeader));
        for i=1:length(subjCodenames)
            if ~isvarname(subjCodenames{i}) && ~isempty(subjCodenames{i})
                subjCodenames{i}=genvarname(subjCodenames{i});
            end
            if ~isvarname(targetTrialIDs{i}) && ~isempty(targetTrialIDs{i})
                targetTrialIDs{i}=genvarname(targetTrialIDs{i});
            end
        end
        logVar(numHeaderRows+1:end,ismember(logVar(1,:),subjIDColHeader))=subjCodenames;
        logVar(numHeaderRows+1:end,ismember(logVar(1,:),targetTrialIDColHeader))=targetTrialIDs;
    end

    save(logsheetPathMAT,'logVar','-v6'); % Save the MAT file version of the logsheet.    

    NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT=logsheetPathMAT;    

    resetProjectAccess_Visibility(fig,4);

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
delete(handles.Import.logVarsUITree.Children);
headerNames=logVar(1,:);
headerNamesVars=genvarname(headerNames);
[~,idx]=sort(upper(headerNamesVars));
headerNamesVars=headerNamesVars(idx);
headerNames=headerNames(idx);
for i=1:size(logVar,2)

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
        handles.Import.dataTypeDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType;
        handles.Import.trialSubjectDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject;
    end

end

% If there's no Digraph in the projectSettingsMATPath, make one and plot
% it.
% Fill in processing map figure
projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

if ismember('Digraph',projectSettingsVarNames)
%     load(projectSettingsMATPath,'Digraph');    
    Digraph=getappdata(fig,'Digraph');
else
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
    
    splitName={'Default'};
    splitCode='001';
    maxSplitCode=splitCode;
    NonFcnSettingsStruct.Process.Splits.SubSplitNames.(splitName{1}).Code=splitCode;
    NonFcnSettingsStruct.Process.Splits.SubSplitNames.(splitName{1}).Name=splitName;   
    NonFcnSettingsStruct.Process.Splits.SubSplitNames.(splitName{1}).Color=[0 0.4470 0.7410]; % MATLAB R2021b first color in default color order

%     save(projectSettingsMATPath,'Digraph','NonFcnSettingsStruct','maxSplitCode','-append');
    save(projectSettingsMATPath,'maxSplitCode','-append');
    setappdata(fig,'Digraph',Digraph);
    setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
end

%% Add the splits UI tree nodes on the Process tab
delete(handles.Process.splitsUITree.Children);
h=findobj(handles.Process.mapFigure,'Type','GraphPlot');
delete(h);
getSplitNames(NonFcnSettingsStruct.Process.Splits,[],handles.Process.splitsUITree);

if ~isempty(Digraph.Edges)
%     load([getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'RGB XKCD - Custom' slash 'xkcd_rgb_data.mat'],'rgblist');
%     edgeColorsIdx=NaN(size(Digraph.Edges.Color,1),1);
%     for i=1:size(Digraph.Edges.Color,1)
%         edgeColorsIdx(i)=find(ismember(round(rgblist,3),round(Digraph.Edges.Color(i,:),3),'rows')==1);
%     end
% 
%     colormap(handles.Process.mapFigure,rgblist);

    h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.4470 0.7410],'Interpreter','none');
    h.EdgeColor=Digraph.Edges.Color;
    splitsUITreeSelectionChanged(fig,'Default (001)');
else
    plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.4470 0.7410],'Interpreter','none');
end

% save(projectSettingsMATPath,'NonFcnSettingsStruct','-append'); % Save the struct back to file.
setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
resetProjectAccess_Visibility(fig,4);

if runLog
    desc='Update the logsheet path';
    updateLog(fig,desc,logsheetPath);
end