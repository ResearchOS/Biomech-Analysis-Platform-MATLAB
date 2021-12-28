function [inclStruct]=specifyTrials_Template()

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

%% Subject Names: (should match folder & logsheet names)
% Examples of each condition sub-type:
% inclStruct.Include.Condition(1).Logsheet(1).Name
% inclStruct.Include.Condition(1).Logsheet(1).Value
% inclStruct.Exclude.Condition(1).Logsheet(1).Name
% inclStruct.Exclude.Condition(1).Logsheet(1).Value
% inclStruct.Include.Condition(1).Structure(1).Name
% inclStruct.Include.Condition(1).Structure(1).Value
% inclStruct.Exclude.Condition(1).Structure(1).Name
% inclStruct.Exclude.Condition(1).Structure(1).Value

%% Try multiple multi-step conditions:
inclStruct.ConditionNames=["Straight";"Preplanned";"Latecued"]; % IN SAME ORDER AS THE CONDITIONS

% Inclusion Condition 1
inclStruct.Include.Condition(1).Logsheet(1).Name='Trial Type/Task'; % The Name name (from logsheet)
inclStruct.Include.Condition(1).Logsheet(1).Value='Straight'; % The desired value(s) for that Name
inclStruct.Include.Condition(1).Logsheet(2).Name='Perfect Trial?';
inclStruct.Include.Condition(1).Logsheet(2).Value='1';
inclStruct.Include.Condition(1).Logsheet(3).Name='Researcher Comments (if any)';
inclStruct.Include.Condition(1).Logsheet(3).Value='~Practice';

% Inclusion Condition 2
inclStruct.Include.Condition(2).Logsheet(1).Name='Trial Type/Task';
inclStruct.Include.Condition(2).Logsheet(1).Value={'TWW';'Pre'};
inclStruct.Include.Condition(2).Logsheet(2).Name='Researcher Comments (if any)';
inclStruct.Include.Condition(2).Logsheet(2).Value='~Practice';
inclStruct.Include.Condition(2).Logsheet(3).Name='Side Of Interest';
inclStruct.Include.Condition(2).Logsheet(3).Value='L';
inclStruct.Include.Condition(2).Logsheet(4).Name='Perfect Trial?';
inclStruct.Include.Condition(2).Logsheet(4).Value='1';

% Inclusion Condition 3
inclStruct.Include.Condition(3).Logsheet(1).Name='Trial Type/Task';
inclStruct.Include.Condition(3).Logsheet(1).Value={'TWW';'Late'};
inclStruct.Include.Condition(3).Logsheet(2).Name='Perfect Trial?';
inclStruct.Include.Condition(3).Logsheet(2).Value='1';
inclStruct.Include.Condition(3).Logsheet(3).Name='Researcher Comments (if any)';
inclStruct.Include.Condition(3).Logsheet(3).Value='~Practice';
inclStruct.Include.Condition(3).Logsheet(4).Name='Side Of Interest';
inclStruct.Include.Condition(3).Logsheet(4).Value='L';

%% Ensure that everything is wrapped up in a cell.
[inclStruct]=wrapInCell(inclStruct);