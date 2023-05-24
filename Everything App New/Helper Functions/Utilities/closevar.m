function []=closevar(varName)

%% PURPOSE: THE OPPOSITE OF MATLAB'S BUILTIN OPENVAR. CLOSES THE SPECIFIED VARIABLE EXPLORER WINDOW.
% Solution taken from here: https://www.mathworks.com/matlabcentral/answers/345583-close-all-variable-editor-windows

desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
Titles  = desktop.getClientTitles;
titleIdx=find(contains(string(Titles),varName)==1);

for i=1:length(titleIdx)
    Client = desktop.getClient(Titles(titleIdx(i)));
    if ~isempty(Client) && ...
            strcmp(char(Client.getClass.getName), 'com.mathworks.mde.array.ArrayEditor')
        Client.close();
    end
end