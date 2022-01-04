function []=saveAndStoreVars(outVar,dataPath)

%% PURPOSE: SAVE TO FILE AND STORE TO PROJECTSTRUCT THE OUTPUT VARIABLES FROM EACH ITERATION OF A PROCESSING FUNCTION
% Inputs:
% outVar: The output from one iteration of one processing function (struct)
% dataPath: The root path name to save the data to.

% outVar format:
% outVar(n).Data=dataVar; % The actual data to be stored & saved.
% outVar(n).Path=path; % The path to store the data to in the struct. Also convert this path to a file path to save the data to file.

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

if isequal(dataPath(end),slash)
    dataPath=dataPath(1:end-1);
end

for i=1:length(outVar)
    
    % Store the data
    assignin('base',outVar(i).Data,'currDataVar'); % Send the actual data to the base workspace.
    assignin('base',outVar(i).Path,'currDataPath'); % Send the data path to the base workspace.
    evalin('base',[outVar(i).Path '=' outVar(i).Data ';']); % Store the data into the projectStruct
    
    % Save the data
    filePath=dataPath;    
    structPath=strsplit(outVar(i).Path,'.');
    
    if length(structPath)==1
         % Save the entire projectStruct
         continue;
    end
    
    for j=2:length(structPath)  
        if isequal(structPath{j}(1:6),'Method') && isstrprop(structPath{j}(7),'digit') && isstrprop(structPath{j}(end),'alpha')
            folderPath=filePath;
            filePath=[filePath slash structPath{j}]; 
            break; % Stop when reaching the Method number & letter field, because it's possible that there are subfields within it which should be kept together.
        end
        filePath=[filePath slash structPath{j}];        
    end
    
    filePath=[filePath '.mat'];
    
    if exist(folderPath,'folder')~=7
        mkdir(folderPath);
    end
    
    % Save the data
    save(filePath,evalin('base','currDataVar'));
    
end