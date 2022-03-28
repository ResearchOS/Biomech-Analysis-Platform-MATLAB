function [trialNames,logVar]=getTrialNames(inclStruct,logVar,src,org,projectStruct)

%% PURPOSE: RETURN THE TRIAL NAMES OF INTEREST SPECIFIED BY THE INCLUSION CRITERIA. UPDATED FOR GUI SPECIFYTRIALS
% Inputs:
% inclStruct: Output from specifyTrials (struct)
% logVar: The logsheet variable, loaded from .mat file (m x n cell)
% src: The figure variable. Not guaranteed to be the fig ancestor. (fig handle)
% org: Specify how to organize the trial names. 0 to organize just by
% subject names, 1 to organize by condition, then subject and trial name (double)
% projectStruct: (OPTIONAL) The struct containing all of the data (struct)

% Outputs:
% trialNames: The list of trial names
% logVar: The updated logsheet variable, because the subject & trial names may have changed

if ~exist('org','var')
    org=0;
end

fig=ancestor(src,'figure','toplevel');

% Subject ID Column Header Name
subjIDColHeaderField=findobj(fig,'Type','uieditfield','Tag','SubjIDColumnHeaderField');
subjIDHeaderName=subjIDColHeaderField.Value;

% Target Trial ID Column Header Name
targetTrialIDColHeaderField=findobj(fig,'Type','uieditfield','Tag','TargetTrialIDColHeaderField');
targetTrialIDColHeaderName=targetTrialIDColHeaderField.Value;

% Number of Header Rows
numHeaderRowsField=findobj(fig,'Type','uinumericeditfield','Tag','NumHeaderRowsField');
numHeaderRows=numHeaderRowsField.Value;

%% LOGSHEET-SPECIFIC CRITERIA
% Iterate over Inclusion vs. Exclusion criteria in Logsheet
inclExcl=fieldnames(inclStruct); % Include and/or Exclude
inclExcl=inclExcl(~ismember(inclExcl,'ConditionNames'));

if ~isempty(logVar) % The logVar is empty if no logsheet criteria specified.
    [~,targetTrialIDColNum]=find(strcmp(logVar(1,:),targetTrialIDColHeaderName));
    [~,subjIDColNum]=find(strcmp(logVar(1,:),subjIDHeaderName));
end

saveLog=0; % Default not to resave the logsheet variable.

for inclExcl=1:2

    switch inclExcl
        case 1
            type='Include';
        case 2
            type='Exclude';
    end

    clear trialNames;

    if ~isfield(inclStruct,type)
        continue; % If no exclusion criteria, ignore it.
    end

    logOrStruct=fieldnames(inclStruct.(type).Condition); % Indicate if struct entries present (logsheet always present)

    for rowNum=numHeaderRows+1:size(logVar,1) % Iterate over each row, starting with first non-header entry

        if isequal(logVar{rowNum,targetTrialIDColNum},logVar{rowNum-1,targetTrialIDColNum})
            repNum=repNum+1; % Incremented when this row's trial name matches the previous row's
        else
            repNum=1; % Initialize that the repetition number is 1.
        end

        for condNum=1:length(inclStruct.(type).Condition)

            if isempty(inclStruct.(type).Condition)
                continue;
            end

            logOrStruct=logOrStruct(~ismember(logOrStruct,'Name')); % Remove the Name entry
            for j=1:length(logOrStruct)

                currLogOrStruct=logOrStruct{j};
                passedCurrSubCond=zeros(1,length(logOrStruct));
                currSubCond=inclStruct.(type).Condition(condNum).(currLogOrStruct);

                switch currLogOrStruct
                    case 'Logsheet' % Logsheet criteria
                        passAllSubConds=zeros(length(currSubCond),1);
                        for l=1:length(currSubCond) % Loop through subconditions
                            % Only ever 1 name, could be multiple values
                            currName=inclStruct.Include.Condition(condNum).Logsheet(l).Name;
                            currVals=inclStruct.Include.Condition(condNum).Logsheet(l).Value;
                            currLogic=inclStruct.(type).Condition(condNum).Logsheet(l).Logic;

                            if isequal(currLogic,'ignore')
                                passAllSubConds(l)=1;
                                continue; % Ignores the current logsheet header
                            end

                            if ~iscell(currVals)
                                currVals={currVals};
                            end

                            [~,currColNum]=find(strcmp(logVar(1,:),currName));
                            try
                                assert(~isempty(currColNum));
                            catch
                                error(['Condition ' num2str(k) ' Logsheet Sub-Condition ' num2str(l) ' Name is Wrong: ' currName{1}]);
                            end
                            currLogElem=logVar{rowNum,currColNum};

                            % Determine if AND or OR logic
                            if size(currVals,1)>=size(currVals,2)
                                andLogic=1;
                            else
                                andLogic=0;
                            end

                            if isa(currLogElem,'double')
                                currLogElem=num2str(currLogElem);
                            end

                            assert(isa(currLogElem,'char'));

                            passAll=zeros(length(currVals),1); % Default that none of the criteria are met.
                            for m=1:length(currVals)

                                currVal=currVals{m}; % Should always be specified as a char, even when using < or > signs
                                invFlag=0; % Initialize this flag to indicate that the logic should not be inverted.

                                if isequal(currVal(1),'~')
                                    currVal=currVal(2:end);
                                    invFlag=1; % Indicates that the logic has been inverted.
                                    origLogic=currLogic; % Preserve the original value to switch back to it.
                                    switch currLogic
                                        case 'is'
                                            currLogic='is not';
                                        case 'is not'
                                            currLogic='is';
                                        case 'contains'
                                            currLogic='does not contain';
                                        case 'does not contain'
                                            currLogic='contains';
                                    end                                   
                                end

                                % IMPLEMENT THE VARIOUS LOGIC GATES HERE
                                switch currLogic
                                    case 'is'
                                        if isequal(currVal,currLogElem)
                                            passAll(m)=1;
                                        end
                                    case 'is not'
                                        if ~isequal(currVal,currLogElem)
                                            passAll(m)=1;
                                        end
                                    case 'contains'
                                        if ~isempty(strfind(currLogElem,currVal))
                                            passAll(m)=1;
                                        end
                                    case 'does not contain'
                                        if isempty(strfind(currLogElem,currVal))
                                            passAll(m)=1;
                                        end
                                    case 'is empty'
                                        if isnan(currLogElem)
                                            passAll(m)=1;
                                        end
                                    case 'is not empty'
                                        if ~isnan(currLogElem)
                                            passAll(m)=1;
                                        end
                                    case 'less than'
                                        if str2double(currLogElem)<str2double(currVal)
                                            passAll(m)=1;
                                        end
                                    case 'greater than'
                                        if str2double(currLogElem)>str2double(currVal)
                                            passAll(m)=1;
                                        end                                        
                                end

                                if invFlag==1
                                    currLogic=origLogic; % Switch back to the original logic value
                                end

                                %                                 if isequal(currVal(1),'~') % Logsheet entry not containing specifyTrials
                                %                                     if ~contains(currLogElem,currVal(2:end))
                                %                                         passAll(m)=1;
                                %                                     end
                                %                                 elseif isequal(currVal(1),'<') % Logsheet entry less than in specifyTrials
                                %                                     if str2double(currLogElem)<str2double(currVal(2:end))
                                %                                         passAll(m)=1;
                                %                                     end
                                %                                 elseif isequal(currVal(1),'>') % Logsheet entry greater than in specifyTrials
                                %                                     if str2double(currLogElem)>str2double(currVal(2:end))
                                %                                         passAll(m)=1;
                                %                                     end
                                %                                 else % Logsheet entry matching specifyTrials
                                %                                     if contains(currLogElem,currVal)
                                %                                         passAll(m)=1;
                                %                                     end
                                %                                 end

                            end

                            if andLogic==1 && all(passAll) % This row passes the criteria
                                passAllSubConds(l)=1;
                            elseif andLogic==0 && any(passAll) % This row passes the criteria
                                passAllSubConds(l)=1;
                            end

                        end

                        % All subconditions in this condition were met.
                        if all(passAllSubConds)
                            passedCurrSubCond(j)=1;
                        end

                    case 'Structure' % Structure criteria

                end

            end

            if all(passedCurrSubCond)

                subName=logVar{rowNum,subjIDColNum};
                if ~isvarname(subName)
                    subName=['S' subName];
                    if ~isvarname(subName)
                        error(['Invalid Subject Name: ' subName(2:end)]);
                    end
                    logVar{rowNum,subjIDColNum}=subName;
                    saveLog=1;
                end
                trialName=logVar{rowNum,targetTrialIDColNum};
                if ~isvarname(trialName)
                    trialName=['T' trialName];
                    if ~isvarname(trialName)
                        error(['Invalid Trial Name: ' trialName(2:end)]);
                    end
                    logVar{rowNum,targetTrialIDColNum}=trialName;
                    saveLog=1;
                end

                if org==0
                    if ~exist('trialNames','var') || ~isfield(trialNames,subName)
                        trialNames.(subName).(trialName)=repNum;
                    elseif isfield(trialNames,subName) && ~isfield(trialNames.(subName),trialName)
                        trialNames.(subName).(trialName)=repNum;
                    else
                        trialNames.(subName).(trialName)=[trialNames.(subName).(trialName) repNum];
                    end
                elseif org==1
                    if ~exist('trialNames','var')
                        trialNames.Condition(condNum).(subName).(trialName)=repNum;
                    elseif length(trialNames.Condition)<condNum
                        trialNames.Condition(condNum).(subName).(trialName)=repNum;
                    elseif ~isempty(trialNames.Condition(condNum)) && ~isfield(trialNames.Condition(condNum),subName)
                        trialNames.Condition(condNum).(subName).(trialName)=repNum;
                    elseif isfield(trialNames.Condition(condNum),subName) && ~isfield(trialNames.Condition(condNum).(subName),trialName)
                        trialNames.Condition(condNum).(subName).(trialName)=repNum;
                    else
                        trialNames.Condition(condNum).(subName).(trialName)=[trialNames.Condition(condNum).(subName).(trialName) repNum];
                    end
                end
                break;
            end

        end

    end

    % Store the found trials to the include or exclude structs.
    switch inclExcl
        case 1
            inclNames=trialNames;
        case 2
            exclNames=trialNames;
    end

end

if saveLog==1
    save(getappdata(fig,'LogsheetMatPath'),'logVar'); % Save the logsheet variable because the subject names & trial names may have changed
end

if ~exist('exclNames','var')
    trialNames=inclNames; % No trials to exclude
    return;
end

% Remove the excluded trials from the included trials list
exclSubNames=fieldnames(exclNames);

for subNum=1:length(exclSubNames)
    subName=exclSubNames{subNum};
    trialNames=fieldnames(exclNames.(subName));
    for trialNum=1:length(trialNames)
        trialName=trialNames{trialNum};
        for repNum=exclNames.(subName).(trialName)
            if existField(inclNames,['inclNames.' subName '.' trialName]) && isequal(inclNames.(subName).(trialName),repNum) % The repetition to be excluded exists in the inclStruct.
                inclNames.(subName).(trialName)=inclNames.(subName).(trialName)(~ismember(inclNames.(subName).(trialName),repNum)); % Remove the repetition number
            end
        end
        if isempty(inclNames.(subName).(trialName)) % If all repetitions of this trial were removed, remove the trial name
            inclNames.(subName)=rmfield(inclNames.(subName),trialName);
        end
    end
    if isempty(fieldnames(inclNames.(subName)))
        inclNames=rmfield(inclNames,subName);
    end
end

if isempty(inclNames) || isempty(fieldnames(inclNames))
    error('No subjects or trials left in inclStruct!');
end

trialNames=inclNames;