function setArg(subName,trialName,repNum,varargin)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)
% repNum: The repetition number for the current trial (double)
% varargin: The value of each output argument. The name passed in to this function must exactly match what is in the input arguments function (any data type)

if ~isempty(repNum) && ~isempty(trialName)
    level='Trial';
elseif ~isempty(subName)
    level='Subject';
else
    level='Project';
end

st=dbstack;
fcnName=st(2).name; % The name of the calling function.

argNames=cell(length(varargin),1);
nArgs=length(varargin);
for i=4:nArgs+3
    argNames{i-3}=inputname(i); % NOTE THE LIMITATION THAT THERE CAN BE NO INDEXING USED IN THE INPUT VARIABLE NAMES
    if isempty(argNames{i-3})
        error(['Argument #' num2str(i) ' (output variable #' num2str(i-3) ') is not a scalar name in ' fcnName ' line #' num2str(st(2).line)]);
    end
end

st=dbstack;
fcnName=st(2).name;
fig=evalin('base','gui;');
methodLetter=getappdata(fig,'methodLetter');
splitName=strsplit(fcnName,'_');
methodNum=splitName{end}(isstrprop(splitName{end},'digit'));

% useGroupArgs=0; % 1 to use group args, 0 not to. This will be replaced by GUI checkbox value later.
% if useGroupArgs==1
%     
% else
%     argsFuncName=[fcnName methodLetter];
% end

guiTab=getappdata(fig,'guiTab');

%% Relate the argNames to the arg function names
[text]=readAllArgsTextFile(getappdata(fig,'everythingPath'),getappdata(fig,'projectName'),getappdata(fig,'guiTab'));
[argsFcnNames,argsNamesInCode]=getAllArgNames(text,getappdata(fig,'projectName'),guiTab,getappdata(fig,'groupName'),[fcnName methodLetter]);

argsFcnName=cell(length(argNames),1);
argCount=0;
for j=1:length(argNames)
    for i=1:length(argsNamesInCode)

        currArgNameInCode=argsNamesInCode{i};
        currArgNameSplit=strsplit(currArgNameInCode,',');
        beforeCommaSplit=strsplit(currArgNameSplit{1},' ');
        %     afterCommaSplit=strsplit(currArgNameSplit{2},' ');

        if isequal(beforeCommaSplit{1},'0') && isequal(beforeCommaSplit{2},argNames{j})
            argCount=argCount+1;
            argsFcnName{argCount}=[guiTab 'Arg_' argsFcnNames{i}];
        end

    end
end

saveLevels=cell(length(argNames),1);

inOut='out';
for i=1:length(argNames)
    argName=argNames{i};
    currFcnName=argsFcnName{i};   
    argIn=feval(currFcnName,inOut,evalin('base','projectStruct;'),subName,trialName,repNum);

%     if isfield(argIn,argName)
%         if ~ischar(argIn.(argName)) || ~isequal(argIn.(argName)(1:length('projectStruct')),'projectStruct')
%             continue;
%         end
%     else
%         warning(['Missing field name: ' argName ' In args function!']);
%         return;
%     end

    saveLevels{i}='Project';
    
    % Resolve the path names (i.e. subName & trialName)
    splitPath=strsplit(argIn,'.');
    resPath=splitPath{1}; % Initialize the resolved path name
    for j=2:length(splitPath)
        if ismember(j,[2 3]) && isequal(splitPath{j}([1 end]),'()') % Dynamic subject or trial name
            dynamicName=splitPath{j}(2:end-1);
            if any(ismember('()',dynamicName)) % There is an index in this field name
                % error? Or ok for trial names?
            else
                if j==2 && isequal(dynamicName,'subName')
                    resPath=[resPath '.' subName];
                    saveLevels{i}='Subject';
                elseif j==3 && isequal(dynamicName,'trialName')
                    resPath=[resPath '.' trialName];
                    saveLevels{i}='Trial';                    
                end
            end
        else
            if j==4 && all(ismember('()',splitPath{j})) && ~isequal(splitPath{j}([1 end]),'()') % There are parentheses in this field name, but it is not a dynamic field name.
                % Check if there are multiple repetitions in this trial.
                openParensIdx=strfind(splitPath{j},'(');
                resPath=[resPath '.' splitPath{j}(1:openParensIdx-1) '(' num2str(repNum) ')'];
            else
                resPath=[resPath '.' splitPath{j}];
            end
        end
        if contains(resPath,'..') % subName or trialName was entered at the wrong level.
            error('Subject or trial name in output arg entered at the wrong level!');
%             return;
        end
    end   
    
%     resPath=[resPath '.Method' methodNum methodLetter]; % Automatically assign the method ID       
    
    assignin('base','currData',varargin{i}); % Store the data to the base workspace.
    evalin('base',[resPath '=currData;']); % Store the data to the projectStruct in the base workspace.

    %% Cut off the paths by level
    savePathsByLevel.(saveLevels{i}).FullPaths{i,1}=resPath;
    dotIdx=strfind(resPath,'.');
    switch saveLevels{i}
        case 'Project'
            savePathsByLevel.(saveLevels{i}).Paths{i,1}=resPath;
        case 'Subject'
            savePathsByLevel.(saveLevels{i}).Paths{i,1}=resPath(dotIdx(2)+1:end); % subName. ...
        case 'Trial'
            savePathsByLevel.(saveLevels{i}).Paths{i,1}=resPath(dotIdx(3)+1:end); % trialName. ...
    end
    
end

evalin('base','clear currData;');

%% Store the save paths by level to the figure variable
fig=evalin('base','gui;');
savePathsByLevelFig=getappdata(fig,'savePathsByLevel');

currLevels=fieldnames(savePathsByLevel);
for i=1:length(currLevels)

    savePathsByLevelFig.(currLevels{i}).Paths=[savePathsByLevelFig.(currLevels{i}).Paths; savePathsByLevel.(currLevels{i}).FullPaths];

end

setappdata(fig,'savePathsByLevel',savePathsByLevelFig);