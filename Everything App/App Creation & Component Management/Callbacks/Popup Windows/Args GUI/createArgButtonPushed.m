function []=createArgButtonPushed(src,event)

%% PURPOSE: ADD NEW ARG TO THE ALL ARGS LIST

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
guiTab=getappdata(fig,'guiTab');

% 1. Open a dialog box asking for the nickname to use for the argument
input=inputdlg('Enter argument nickname');

if isempty(input) || isempty(input{1})
    return; % Operation cancelled or nothing entered.
end

assert(length(input)==1);
input=input{1};

if contains(input,':')
    warning('Colon not allowed in nickname!')
    return;
end

input=strtrim(input);
input(isspace(input))='_'; % Replace spaces with underscores

if ~isvarname(input)
    warning('Improper argument nickname! Spaces are ok, but otherwise must evaluate to valid MATLAB variable name!');
    return;
end

% 2. If this argument name already exists in the list, ask if want to overwrite.

% 3. If does not exist, or overwriting, put the argument name and its corresponding function name into the text file.
[text,currProjectArgsTxtPath]=readAllArgsTextFile(getappdata(fig,'everythingPath'));
if ~isempty(text)
    allArgsList=getAllArgNames(text,getappdata(fig,'projectName'),guiTab);
else
    allArgsList='';
end

% 4. Update the 'All' args list box with the new entries.
allArgsListBox=handles.allArgsListBox;

if isempty(allArgsList) % New project, no args yet
    allArgsListBox.Items={input};
else
    allArgsListBox.Items=sort(unique([allArgsListBox.Items {input}]));
end

groupName='Unassigned';
fcnName=['Unassigned_' getappdata(fig,'guiTab') '1A'];
writeAllArgsTextFile(currProjectArgsTxtPath,getappdata(fig,'guiTab'),groupName,fcnName,input,getappdata(fig,'projectName'),'0 , 1 ','Enter Description Here');
