function projectStruct=importProject(projectStruct)

%% PURPOSE: WRAPPER FOR IMPORT PROJECT INFO AND IMPORT SUBJECT (WHICH WRAPS IMPORT TRIAL)
% Inputs:
% projectStruct: All subjects all data (struct)

% Outputs:
% projectStruct: All subjects all data (struct)

st=dbstack;
fName=st(1).name;

%% Specify trial names for import
cd(projectStruct.Info.ProjectPath);
addpath(genpath(cd)); % Add all subfolders of the project folder.
% currCD=cd('SpecifyTrials');
inclStruct=feval(['specifyTrials_' fName],projectStruct.Info.LogsheetPath,projectStruct.Info.ProjectPath,projectStruct.Info.ProjectName); % Specify metadata to use to isolate trials of interest.
% cd(currCD);
[trialsOfInt,ProjHelper,logsheet]=getValidTrialNames(projectStruct.Info.LogsheetPath,0,inclStruct); % Trial names of interest for importing/loading.

% Get the list of all subject names used in the logsheet. Use this to identify placeholders in the projectStruct.
[~,subIDCol]=find(strcmp(logsheet(1,:),ProjHelper.Info.ColumnNames.Subject.Codename),1,'first');
subNamesInLogsheet=unique(logsheet(4:end,subIDCol),'stable');

projectStruct.Info.ProjHelper=ProjHelper;

% cd(currCD); % Switch current directory to projectPath
cd('Subject Data'); % Down into Subject Data folder (contains all subjects' data folders)

if ~isfield(projectStruct,'Subject') % If projectStruct has no data in it, initialize it.
    projectStruct=importProjectInfo(projectStruct,ProjHelper,projectStruct.Info.ProjectPath,projectStruct.Info.ProjectName,projectStruct.Info.LogsheetPath,projectStruct.Info.Flags);
    projectStruct.Subject(length(subNamesInLogsheet),1)=struct;
end
for subIter=1:length(ProjHelper.Info.SubjectList) % For each subject.    
    subName=ProjHelper.Info.SubjectList{subIter};
    subNameLetters=subName(isletter(subName));
    sub=find(contains(subNamesInLogsheet,subName),1,'first');
    assignin('base','sub',sub); % For storing the data to base projectStruct.
    if isfield(trialsOfInt,subNameLetters)
        currTrialsList=getCurrTrialsList(trialsOfInt.(subNameLetters)); % Get list of current subject's trial names.
    end
    
    % Operate on one subject at a time.
    projectStruct=importSubjectC3D(subName,projectStruct,sub,ProjHelper,logsheet,projectStruct.Info.Flags,currTrialsList,projectStruct.Info.ProjectName);
end
cd(projectStruct.Info.ProjectPath); % Leave off in the project directory.