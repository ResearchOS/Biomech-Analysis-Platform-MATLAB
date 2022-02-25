function [trialNames,logVar]=getTrialNames(inclStruct,logVar,src,org,projectStruct)

%% PURPOSE: RETURN THE TRIAL NAMES OF INTEREST SPECIFIED BY THE INCLUSION CRITERIA
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

% Inclusion
for rowNum=numHeaderRows+1:size(logVar,1) % Iterate over each row, starting with first non-header entry

    if isequal(logVar{rowNum,targetTrialIDColNum},logVar{rowNum-1,targetTrialIDColNum})
        repNum=repNum+1; % Incremented when this row's trial name matches the previous row's
    else
        repNum=1; % Initialize that the repetition number is 1.
    end
    
    for i=1:length(inclExcl)
        currInclExcl=inclStruct.(inclExcl{i});
        logsheetOrStruct=fieldnames(currInclExcl.Condition);
        
        if isequal(inclExcl{i},'Include')
            
            for k=1:length(currInclExcl.Condition)
                
                if isempty(currInclExcl.Condition(k))
                    continue;
                end
                
                for j=1:length(logsheetOrStruct)
                    
                    passedCurrSubCond=zeros(1,length(logsheetOrStruct)); % One element is logsheet, other element is structure.
                    currSubCond=inclStruct.Include.Condition(k).(logsheetOrStruct{j});
                    
                    if isequal(logsheetOrStruct{j},'Logsheet')
                        
                        passAllSubConds=zeros(length(currSubCond),1);
                        for l=1:length(currSubCond) % Loop through subconditions
                            % Only ever 1 name, could be multiple values
                            currName=inclStruct.Include.Condition(k).Logsheet(l).Name;
                            currVals=inclStruct.Include.Condition(k).Logsheet(l).Value;
                            
                            [~,currColNum]=find(strcmp(logVar(1,:),currName{1}));
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
                                
                                if isequal(currVal(1),'~') % Logsheet entry not containing specifyTrials
                                    if ~contains(currLogElem,currVal(2:end))
                                        passAll(m)=1;
                                    end
                                elseif isequal(currVal(1),'<') % Logsheet entry less than in specifyTrials
                                    if str2double(currLogElem)<str2double(currVal(2:end))
                                        passAll(m)=1;
                                    end
                                elseif isequal(currVal(1),'>') % Logsheet entry greater than in specifyTrials
                                    if str2double(currLogElem)>str2double(currVal(2:end))
                                        passAll(m)=1;
                                    end
                                else % Logsheet entry matching specifyTrials
                                    if contains(currLogElem,currVal)
                                        passAll(m)=1;
                                    end
                                end
                                
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
                        
                    elseif isequal(logsheetOrStruct{j},'Structure')
                        
                        
                        
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
                                trialNames.Condition(k).(subName).(trialName)=repNum;
                            elseif length(trialNames.Condition)<k
                                trialNames.Condition(k).(subName).(trialName)=repNum;
                            elseif ~isempty(trialNames.Condition(k)) && ~isfield(trialNames.Condition(k),subName)
                                trialNames.Condition(k).(subName).(trialName)=repNum;
                            elseif isfield(trialNames.Condition(k),subName) && ~isfield(trialNames.Condition(k).(subName),trialName)
                                trialNames.Condition(k).(subName).(trialName)=repNum;
                            else
                                trialNames.Condition(k).(subName).(trialName)=[trialNames.Condition(k).(subName).(trialName) repNum];
                            end
                        end
                        break;
                    end
                    
                end
                
            end
            
        elseif isequal(inclExcl{i},'Exclude')
            
            
            
        end
        
    end
    
end

if saveLog==1
    save(getappdata(fig,'LogsheetMatPath'),'logVar'); % Save the logsheet variable because the subject names & trial names may have changed
end