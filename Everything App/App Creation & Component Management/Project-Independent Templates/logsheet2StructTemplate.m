function []=logsheet2StructTemplate()

%% PURPOSE: THIS IS THE LOGSHEET2STRUCT TEMPLATE, INDEPENDENT OF ANY PROJECT.

%% Specify header names manually
logFields.ResearcherComments='Researcher Comments (if any)';

%% GUI-specified criteria, automatically filled in
hTargetTrialHeaderName=findobj(fig,'Type','uieditfield','Tag','TargetTrialIDColHeaderField');
hSubjectHeaderName=findobj(fig,'Type','uieditfield','Tag','SubjIDColumnHeaderField');

logFields.TargetTrialName=hTargetTrialHeaderName.Value;
logFields.SubjectName=hSubjectHeaderName.Value;

% Get the header names for trials for each data type.
text=readAllProjects(getappdata(fig,'everythingPath'));
projectNamesInfo=isolateProjectNamesInfo(text,projectName);
fldNames=fieldnames(projectNamesInfo);
prefix='Trial ID Column Header For';
for i=1:length(fldNames)
    fldName=fldNames{i};
    if contains(fldName,prefix)
        colonIdx=strfind(fldName,':');
        dataType=projectNamesInfo.(fldName)(length(prefix)+2:colonIdx-1);
        logFields.(['TrialName' dataType])=projectNamesInfo.(fldName);
    end        
end