function []=addFunctionButtonPushed(src,event)

%% PURPOSE: CREATE A NEW FUNCTION FROM TEMPLATE AND SAVE IT TO FILE. DOES NOT ADD ANYTHING TO THE GUI FIGURE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Make Process functions directory if it does not already exist
processFcnsDir=[getappdata(fig,'codePath') 'Processing Functions'];
if exist(processFcnsDir,'dir')~=7
    mkdir(processFcnsDir);
end

%% Get the function name from the user
while true

    fcnName=inputdlg('Enter Function Name','New Function');

    if isempty(fcnName)
        return;
    end

    if length(fcnName)>1
        disp('One line of text only!');
        continue;
    end

    fcnName=fcnName{1};

    if isvarname(fcnName)
        break;
    end

    disp(['Entered function name is not valid: ' fcnName]);

end

%% Check if the function already exists
if ispc==1
    slash='\';
elseif ismac==1
    slash='/';
end

newFcnPath=[processFcnsDir slash fcnName '.m'];

if exist(newFcnPath,'file')==2
    disp(['Function already exists! ' fcnName]);
    return;
end

%% Get the desired level of the processing function from the user
while true

    fcnLevel=inputdlg('Enter Function Level','Function Level');

    if isempty(fcnLevel)
        return;
    end

    if length(fcnLevel)>1
        disp('One line of text only!');
        continue;
    end

    fcnLevel=sort(upper(fcnLevel{1}));
    
    if all(ismember(fcnLevel,'PST'))
        break;
    end
    
    disp('Function level must be one of: (P)roject, (S)ubject, (T)rial');

end

%% OPTIONAL: Specify the purpose of the function

%% Create the function from template.
templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'Process_Template' fcnLevel '.m'];

createFileFromTemplate(templatePath,newFcnPath,fcnName);