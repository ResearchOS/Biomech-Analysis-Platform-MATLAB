function [bool]=existField(origStruct,structNameIn,varargin)

%% PURPOSE: DETERMINE IF A STRUCT FIELD EXISTS, NO MATTER HOW MANY FIELDS ARE IN IT
% Inputs:
% struct: The actual structure to look through (struct)
% structNameIn: The fully indexed address of the field (char)
% varargin: All of the indexing variables, in order (vector of chars and/or doubles)

structName=strsplit(structNameIn,'.');
openParensIdx=strfind(structName{1},'(');
if isempty(openParensIdx)
    openParensIdx=length(structName{1})+1;
end
fieldname=structName{1}(1:openParensIdx-1); % Can't be dynamic field name, so ok to do this.

struct.(fieldname)=origStruct; % Prepend to handle indexing the top level of the origStruct.
structNameIn=[fieldname '.' structNameIn]; % Prepend to handle indexing the top level of the origStruct.

structParts=strsplit(structNameIn,'.'); % Splits the struct at its dots.
bool=true; % Initialize that the field does exist.
idxNum=0; % Counter for the number of varargin

% Handle indexing in the very first level of structParts
for i=2:length(structParts)

    if any(contains(structParts{i},'(')) % Handle indexing.
        parenIdx=strfind(structParts{i},'(');
    else
        parenIdx=length(structParts{i})+1; % If no indexing, set up to get the whole field name.
    end

    if ismember(1,parenIdx) % Dynamic field name
        idxNum=idxNum+1; % Increment the varargin counter
        assert(idxNum<=length(varargin),'Not enough indices entered!');
        assert(ischar(varargin{idxNum}),'Dynamic field names should be chars!'); % Check that this input variable is a char so that it can evaluate to a field name.
        fieldName=varargin{idxNum}; % Get the field name.
        closeDynamicParensIdx=find(structParts{i}==')',1,'first'); % Get the closing parens idx.
        if length(structParts{i})>closeDynamicParensIdx % Check if there is indexing as well as a dynamic field name here.
            structParts{i}=[fieldName structParts{i}(closeDynamicParensIdx+1:end)];
        else
            structParts{i}=fieldName;
        end
    else
        fieldName=structParts{i}(1:parenIdx-1);
    end

    if ~isfield(struct,fieldName)
        bool=false;
        return;
    end

    if i==length(structParts) % This is the final field, and it exists.
        return;
    end

    if ~any(contains(structParts{i},'(')) % Handle indexed vars.
        struct=struct.(fieldName);
        continue;
    end

    % Here, there is some dynamic indexing going on.
    parenIdx=strfind(structParts{i},'('); % Find the new opening parens
    assert(length(parenIdx)<=1,'Too many parentheses in this field name!'); % Ensure that there's only one.
    idxVars=structParts{i}(parenIdx+1:end-1); % Isolate all of the dynamic indices
    idxVars=strsplit(idxVars,','); % In case of multidimensional inputs.
    hardCodeCount=0; % Number of hard-coded indices in this field name.
    indices=''; % Initialize the indices
    for k=1:length(idxVars)
        if all(isstrprop(idxVars{k},'digit')) % Handle hard-coded index
            hardCodeCount=hardCodeCount+1;
            if (length(idxVars)==1 && length(struct.(structParts{i}(1:parenIdx-1)))<str2double((idxVars{hardCodeCount}))) || ...
                    (length(idxVars)>1 && size(struct.(structParts{i}(1:parenIdx-1)),k)<str2double(idxVars{hardCodeCount})) % Check that this field has this many entries
                bool=false;
                return;
            end
            % Create the indices char vector for evaluation
            if k<length(idxVars)
                indices=[indices idxVars{k} ','];
            else
                indices=[indices idxVars{k}];
            end
        else % Dynamic index
            idxNum=idxNum+1; % Increment which varargin is being used.
            assert(idxNum<=length(varargin),'Not enough indices entered!');
            assert(isnumeric(varargin{idxNum}),'Dynamic indices should be numeric!'); % Check that this input variable is a char so that it can evaluate to a field name.
            if (length(idxVars)==1 && length(struct.(structParts{i}(1:parenIdx-1)))<varargin{idxNum}) || ...
                    (length(idxVars)>1 && size(struct.(structParts{i}(1:parenIdx-1)),k)<varargin{idxNum}) % Check that this field has this many entries
                bool=false;
                return;
            end
            % Create the indices char vector for evaluation
            if k<length(idxVars)
                indices=[indices num2str(varargin{idxNum}) ','];
            else
                indices=[indices num2str(varargin{idxNum})];
            end

        end

    end
    struct=eval(['struct.' fieldName '(' indices ');']); % Evaluate the current dynamically indexed field name.

end