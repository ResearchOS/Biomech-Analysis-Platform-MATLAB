function [psid,psName]=createPSID(piText, class)

%% PURPOSE: CREATE PROJECT-SPECIFIC ID FOR THE SPECIFIED OBJECT.

slash=filesep;

commonPath=getCommonPath();
classFolder=[commonPath slash class];
classFolderProject=[commonPath slash 'Project'];

fullPath=[classFolder slash class '_' piText '.json'];
piStruct=loadJSON(fullPath); % Project-independent struct.

projects=piStruct.Project;
computerID=getComputerID();

isNewID=false;
while ~isNewID
    redoID=false;
    newID=randi(4095,1); % Max 3 digits

    newID=dec2hex(newID); % Convert the randomly generated number to hexadecimal char
    numDigits=length(newID);
    psid=[repmat('0',1,3-numDigits) newID]; % Ensure that the hex code is 6 digits long

    % Check in all projects that this PSID does not already exist.
    for i=1:length(projects)
        fullPath=[classFolderProject slash 'Project_' projects{i} '.json'];
        projectStruct=loadJSON(fullPath);
        projectPath=projectStruct.ProjectPath.(computerID);
        psName=[piText '_' psid]; % Project-specific name.
        psPath=[projectPath slash 'Project_Settings' slash class slash class '_' psName '.json'];
        if exist(psPath,'file')==2            
            redoID=true; 
            break;
        end
    end    

    if ~redoID
        isNewID=true;
    end

end