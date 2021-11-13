function []=processResize(src)

%% RESIZE THE COMPONENTS WITHIN THE PROCESS TAB.

data=src.UserData; % Get UserData to access components.

if isempty(data)
    return; % Called on uifigure creation
end

% Set components to be invisible

fig=ancestor(src,'figure','toplevel');
figSize=src.Position(3:4); % Width x height

h1=findobj(fig,'Tag','Setup'); % Rreturn the Process > Setup tab.
h1.Position=[h1.Position(1:2) figSize];
h2=findobj(fig,'Tag','Run'); % Return the Process > Run tab.
h2.Position=[h1.Position(1:2) figSize];

if isequal(src.Tag,h1.Tag) % Currently in the Setup tab, run the Setup SizeChangedFcn
    processSetupResize(src);
elseif isequal(src.Tag,h2.Tag) % Currently in the Run tab, run the Run SizeChangedFcn
    processRunResize(src);
end