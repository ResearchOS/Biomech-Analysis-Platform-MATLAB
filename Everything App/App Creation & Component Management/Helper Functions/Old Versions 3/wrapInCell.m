function [inclStruct]=wrapInCell(inclStruct)

%% PURPOSE: ENSURE THAT ALL ENTRIES IN THE INCLSTRUCT ARE CELLS, NOT CHARS

inclExcl=fieldnames(inclStruct); % Include and/or Exclude
inclExcl=inclExcl(~ismember(inclExcl,'ConditionNames'));

for i=1:length(inclExcl)
    currInclExcl=inclStruct.(inclExcl{i});
    
    logOrStruct=fieldnames(currInclExcl.Condition);
    for j=1:length(currInclExcl.Condition) % For each condition in the include/exclude struct        
        
        if ~isempty(currInclExcl.Condition(j))
            
            for k=1:length(logOrStruct) % Loop through logsheet & struct conditions
                
                for l=1:length(currInclExcl.Condition(j).(logOrStruct{k}))
                    if ~isstruct(currInclExcl.Condition(j).(logOrStruct{k}))
                        continue; % Temporary for testing new specify trials GUI
                    end
                    
                    condName=currInclExcl.Condition(j).(logOrStruct{k})(l).Name;
                    condVal=currInclExcl.Condition(j).(logOrStruct{k})(l).Value;
                    
                    if ~iscell(condName)
                        inclStruct.(inclExcl{i}).Condition(j).(logOrStruct{k})(l).Name={condName};
                    end
                    if ~iscell(condVal)
                        inclStruct.(inclExcl{i}).Condition(j).(logOrStruct{k})(l).Value={condVal};
                    end
                    
                end
            
            end
            
        end
        
    end
    
end