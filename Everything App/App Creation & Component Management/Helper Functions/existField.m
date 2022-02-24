function [bool]=existField(struct,structNameIn,varargin)

%% PURPOSE: DETERMINE IF A STRUCT FIELD EXISTS, NO MATTER HOW MANY FIELDS ARE IN IT
% Inputs:
% struct: The actual structure to look through (struct)
% structNameIn: The fully indexed address of the field (char)
% varargin: All of the indexing variables, in order (vector of doubles)

structParts=strsplit(structNameIn,'.'); % Splits the struct at its dots.
bool=1; % Initialize that the field does exist.
idxNum=0;
% dynamicFieldNum=0;
for i=2:length(structParts)
    
    if any(contains(structParts{i},'(')) % Handle indexed vars.
        parenIdx=strfind(structParts{i},'(');
        assert(length(parenIdx)==1); % Only one parentheses in here.
    else
        parenIdx=length(structParts{i})+1;
    end
    
    if parenIdx==1 % && isequal(structParts{i}(end),')') % Dynamic field name
        idxNum=idxNum+1;
        fieldName=varargin{idxNum};
        closeDynamicParensIdx=find(structParts{i}==')',1,'first');
        if length(structParts{i})>closeDynamicParensIdx
            structParts{i}=[fieldName structParts{i}(closeDynamicParensIdx+1:end)];
        else
            structParts{i}=fieldName;
        end
    else
        fieldName=structParts{i}(1:parenIdx-1);
    end
    
    if isfield(struct,fieldName)
        if i==length(structParts) % This is the final field, and it exists.            
            return;
        end
        if any(contains(structParts{i},'(')) % Handle indexed vars.     
            idxNum=idxNum+1;
%             structName=[structName '.' structParts{i}(1:parenIdx) num2str(idx(idxNum)) ')'];
            struct=struct.(structParts{i}(1:parenIdx-1))(varargin{idxNum});
        else
%             structName=[structName '.' structParts{i}]; % The current struct address.
            struct=struct.(structParts{i});
        end
    else
        bool=0;
        return; % End the process because the field does not exist.
    end        
    
end