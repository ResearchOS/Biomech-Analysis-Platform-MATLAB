function []=keyPressFcn(fig,key)

%% PURPOSE: DO THINGS BASED ON A KEY PRESS.

% fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');

if isempty(key.Character)
    return;
end

name=key.Key; % The name of the key pressed.
mod=key.Modifier; % The modifier key, if any.

switch name
    case 'uparrow'

    case 'downarrow'

    otherwise

end