function Process_TemplatePS(projectStruct,subNames)

%% PURPOSE: TEMPLATE FOR PROJECT & SUBJECT-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER PROJECT.
% Inputs:
% projectStruct: The entire data struct. Used for saving ONLY.
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% varargin: The input variables from the input arguments function (cell array, each element is one variable)

%% TODO: Assign input arguments to variable names
roomNum=getArg('roomNum'); % Get project level variable

for subNum=1:length(subNames)
    subName=subNames{subNum};
    
    height=getArg('height',subName); % Get subject level variable
    
    setArg(subName,[],[],height); % Set subject level variable
    
end

%% TODO: Biomechanical operations for the whole project.
% Code here.
collectionSite=['Zaferiou Lab ' roomNum];

%% TODO: Store the computed variable(s) data to the projectStruct
setArg([],[],[],collectionSite); % Set project level variable