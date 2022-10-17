function []=addLogVarsRunCode(useHeaderNames,dataTypes,trialSubject,specifyTrials,numHeaderRows,subjIDColHeader,targetTrialIDColHeader)

%% PURPOSE: IN THE RUN CODE, ADD THE LOGSHEET VARIABLES TO THE NONFCNSETTINGSSTRUCT
useHeaderVarNames=genvarname(useHeaderNames);

fig=evalin('base','runCodeHiddenGUI;');

try
    NonFcnSettingsStruct=evalin('base','NonFcnSettingsStruct');
catch
    disp('NonFcnSettingsStruct missing from base workspace! Initializing as empty.');
    NonFcnSettingsStruct='';
end

try
    Digraph=evalin('base','Digraph');
catch
    disp('Digraph missing from base workspace! Initializing as empty.');
    Digraph=digraph;
end

NonFcnSettingsStruct.Import.SubjectIDColHeader=subjIDColHeader;
NonFcnSettingsStruct.Import.TargetTrialIDColHeader=targetTrialIDColHeader;
NonFcnSettingsStruct.Import.NumHeaderRows=numHeaderRows;

for i=1:length(useHeaderNames)
    NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderVarNames{i}).DataType=dataTypes{i};
    NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderVarNames{i}).TrialSubject=trialSubject{i};
end

try
    projectSettingsMATPath=evalin('base','projectSettingsMATPath;');
catch
    disp('Missing the projectSettingsMATPath variable from the base workspace! Stopping.');
    return;
end

assignin('base','NonFcnSettingsStruct',NonFcnSettingsStruct);
setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);

varNames=Digraph.Nodes.Properties.VariableNames;
if isempty(varNames) % Initialize
%     Digraph=digraph;
    Digraph=addnode(Digraph,1);
    Digraph.Nodes.FunctionNames={'Logsheet'};
    Digraph.Nodes.Descriptions={{''}};
    Digraph.Nodes.InputVariableNames{1}=''; % Name in GUI
    Digraph.Nodes.OutputVariableNames{1}=''; % Name in GUI
    Digraph.Nodes.Coordinates=[0 0];
%     Digraph.Nodes.SplitCodes={{'001'}};
    Digraph.Nodes.NodeNumber=1;
    Digraph.Nodes.SpecifyTrials={specifyTrials};
    Digraph.Nodes.IsImport=false;
    Digraph.Nodes.InputVariableNamesInCode{1}=''; % Name in file/code
    Digraph.Nodes.OutputVariableNamesInCode{1}=''; % Name in file/code
    Digraph.Nodes.RunOrder{1}=[];

    assignin('base','Digraph',Digraph);
    setappdata(fig,'Digraph',Digraph);
end

if exist(projectSettingsMATPath,'file')==2
    save(projectSettingsMATPath,'NonFcnSettingsStruct','Digraph','-append');
else
    save(projectSettingsMATPath,'NonFcnSettingsStruct','Digraph');
end