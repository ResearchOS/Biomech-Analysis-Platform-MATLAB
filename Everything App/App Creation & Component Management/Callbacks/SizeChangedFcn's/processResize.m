function []=processResize(src, event)

%% RESIZE THE COMPONENTS WITHIN THE PROCESS TAB.

data=src.UserData; % Get UserData to access components.

if isempty(data)
    return; % Called on uifigure creation
end

fig=ancestor(src,'figure','toplevel');
figSize=fig.Position(3:4); % Width x height

hGroup=findobj(fig,'Tag','ProcessTabGroup');
hGroup.Position=[0 0 figSize(1) figSize(2)-20]; % Resize the Process tab group to be just smaller than the top level tab group.

% if isequal(hGroup.SelectedTab.Tag,'Setup') % Currently in the Setup tab, run the Setup SizeChangedFcn
%     processSetupResize(src);
% elseif isequal(hGroup.SelectedTab.Tag,'Run') % Currently in the Run tab, run the Run SizeChangedFcn
%     processRunResize(src);
% end

processSetupResize(src); % Both subtabs run off of same callback function