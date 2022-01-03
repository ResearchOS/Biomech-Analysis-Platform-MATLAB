function []=fcnArgsButtonPushed(src)

%% PURPOSE: OPEN THE ARGS FUNCTION

fig=ancestor(src,'figure','toplevel');

currTag=src.Tag;
currLetter=src.Text;

if ~isletter(currTag(end-1)) % 2 digits
    elemNum=str2double(currTag(end-1:end));
else % 1 digit
    elemNum=str2double(currTag(end));
end

fcnNames=findobj(fig,'Type','uitextarea','Tag','SetupFunctionNamesField');
fcnNames=fcnNames.Value;

currFcn=fcnNames{elemNum};

fcnElems=strsplit(currFcn,' ');
fcnName=[fcnElems{1} '_Process' fcnElems{2}(isletter(fcnElems{2}))];

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

argsPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Arguments' slash fcnName '.m'];

try
    edit(argsPath);
catch % If the arguments file does not exist, create it from the template.
    
end