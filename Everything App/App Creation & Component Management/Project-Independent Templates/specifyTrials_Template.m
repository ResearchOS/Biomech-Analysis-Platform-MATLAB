function [inclStruct]=specifyTrials_Template(logsheetPath,codePath,projectName)

%% PURPOSE: To specify metadata describing which trials to import/analyze.
% NOTE: DOES NOT ALLOW FOR OVERLAPPING TRIAL NAMES BETWEEN CONDITIONS WHEN STRATIFYING BY CONDITION

%% METHOD OF OPERATION:
% 1: Specify the project path (where Matlab Code & Subject Data folder is located) (CHAR)
% 2: Specify the project name (importSettings name) (CHAR)
% 3: Specify the list of subjects. Should match the folder & logsheet names. (CELL ARRAY OF CHAR)
% 4: Specify the metadata criteria to use, and the values to include/exclude
    % Each condition: inclStruct.Condition(i) -> OR logic. Trial metadata must match ONE of the specified conditions.
    % Each criteria within each condition: inclStruct.Condition(i).(fieldName) -> AND logic. Trial metadata must match ALL of the specified criteria.
        % NOTE: Fieldnames must match the importSettings field name for that metadata.
    % Multiple phrases within each criteria: inclStruct.Condition(i).(fieldName){:} -> AND/OR logic.
        % Row Vector Cell Array: OR logic
        % Column Vector Cell Array: AND logic
        % If some metadata value is NOT desired, first char in that element of the cell array should be a '~'
    % NOTE: CAN DO DIFFERENT RULES FOR DIFFERENT SUBJECTS IF SO DESIRED, BY SPECIFYING DIFFERENT SUBJECT LISTS WITHIN THE VARIOUS CONDITIONS.
        % IF ALL SUBJECTS ABIDE BY THE SAME RULES, CAN OMIT THE SUBJECT LIST FROM THE CONDITION AND IT IS ADDED ON AUTOMATICALLY.
    
%% Project-level attributes.
inclStruct.Project.LogsheetPath=logsheetPath;
inclStruct.Project.CodePath=codePath;
inclStruct.Project.ProjectName=projectName;

%% Subject Names: (should match folder & logsheet names)
%% IF NOT SPECIFIED, ALL SUBJECTS IN LOGSHEET USED.
% Cell array of chars
% Easily take a subset of subjects. OR, specify multiple subject cell arrays and allocate them to different conditions for subject-specific trial
% metadata matching.
% allSubsList={'02_Nairobi','03_Tokyo','04_Denver','06_Berlin','07_Oslo',...
%     '09_Boston','10_Chicago','11_Seattle','12_London','13_Paris'};

%% Try multiple multi-step conditions:
inclStruct.ConditionNames=["Straight";"Preplanned";"Latecued"]; % IN SAME ORDER AS THE CONDITIONS
% OR multi-part condition 1
% TaskType contains Straight && IsPerfect contains 1 && ResearcherComments ~contains Practice && Codename contains subName
% inclStruct.Condition(2).Codename=allSubsList;
inclStruct.Condition(1).TaskType='Straight';
inclStruct.Condition(1).IsPerfect='1';
inclStruct.Condition(1).ResearcherComments='~Practice';
% OR multi-part condition 3
% TaskType contains TWW && IsPerfect contains 1 && ResearcherComments ~contains Practice && SideOfInterest contains L && Codename contains subName
% inclStruct.Condition(3).Codename=allSubsList;
inclStruct.Condition(2).TaskType={'TWW';'Pre'};
inclStruct.Condition(2).IsPerfect='1';
inclStruct.Condition(2).ResearcherComments='~Practice';
inclStruct.Condition(2).SideOfInterest='L';

inclStruct.Condition(3).TaskType={'TWW';'Late'};
inclStruct.Condition(3).IsPerfect='1';
inclStruct.Condition(3).ResearcherComments='~Practice';
inclStruct.Condition(3).SideOfInterest='L';

%% Ensure that everything is wrapped up in a cell.
for i=1:length(inclStruct.Condition) % Each condition
    fldNames=fieldnames(inclStruct.Condition(i));
    fldNames=fldNames(~contains(fldNames,'StructCondition')); % Exclude struct condition field from being wrapped in a cell.
    for j=1:length(fldNames)
        if ~iscell(inclStruct.Condition(i).(fldNames{j}))
            inclStruct.Condition(i).(fldNames{j})={inclStruct.Condition(i).(fldNames{j})};
        end
    end
    structFldNames=fieldnames(inclStruct.Condition(i));
    if any(contains(structFldNames,'StructCondition')) % This condition has a struct condition
        for k=1:length(inclStruct.Condition(i).StructCondition)
            if ~iscell(inclStruct.Condition(i).StructCondition(k).Name)
                inclStruct.Condition(i).StructCondition(k).Name={inclStruct.Condition(i).StructCondition(k).Name};
            end
            if ~iscell(inclStruct.Condition(i).StructCondition(k).Value)
                inclStruct.Condition(i).StructCondition(k).Value={inclStruct.Condition(i).StructCondition(k).Value};
            end
        end
    end
end