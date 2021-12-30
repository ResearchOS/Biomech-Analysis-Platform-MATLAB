function []=fcnArgsButtonPushed(src)

%% PURPOSE: OPEN THE ARGS FUNCTION

fig=ancestor(src,'figure','toplevel');

currTag=src.Tag;

if ~isletter(currTag(end-1)) % 2 digits
    currNum=str2double(currTag(end-1:end));
else % 1 digit
    currNum=str2double(currTag(end));
end

% Get the handle for the function names button
hNameButton=findobj(fig,'Type','uibutton','Tag',['OpenFcnButton' num2str(currNum)]);

fcnName=hNameButton.Text;

edit();