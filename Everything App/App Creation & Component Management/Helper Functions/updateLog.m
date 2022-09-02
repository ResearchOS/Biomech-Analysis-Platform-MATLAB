function []=updateLog(fig,desc,varargin)

%% PURPOSE: UPDATE THE RUN LOG WITH THE MOST RECENTLY PERFORMED STEP.

fig=ancestor(fig,'figure','toplevel');

logPath=getappdata(fig,'runLogPath');

if ~getappdata(fig,'logEverCreated')
    return; % This is most likely initialization, don't show the error message.
end

if exist(logPath,'file')~=2
    disp(['Missing the run log file! Expected at: ' logPath]);
    return;
end

text=regexp(fileread(logPath),'\n','split');
text=text(1:end-2); % Remove the setappdata(fig,'isRunLog','false')

if size(text,1)<size(text,2) % Row vector
    text=text';
end

if ~isempty(text{end})
    text{end+1}='';
end

n=length(text);

n=n+1;
text{n}=['% ' desc]; % Insert the description

n=n+1;
text{n}=['% ' char(datetime('now'))];

st=dbstack;
fcnName=st(2).name;

% Get the names of the variables that were input.
argsChar='(gui, ';
varNames=cell(length(varargin),1);
initNum=3; % The number of non-varargin input variables plus 1.
for i=initNum:length(varargin)+initNum-1
    varNames{i-(initNum-1)}=inputname(i);
    n=n+1;
    varClass=class(varargin{i-(initNum-1)});
    switch varClass
        case 'char'
            text{n}=[varNames{i-(initNum-1)} ' = ' '''' varargin{i-(initNum-1)} ''';']; % Insert the argument definitions

        case 'struct'

        case 'double'
            text{n}=[varNames{i-(initNum-1)} ' = ' '' num2str(varargin{i-(initNum-1)}) ';'];
    end
    if i==initNum
        argsChar=[argsChar varNames{i-(initNum-1)}];
    else
        argsChar=[argsChar ', ' varNames{i-(initNum-1)}];
    end
end

argsChar=[argsChar ');'];

if nargin<3
    argsChar='(gui);';
end

n=n+1;
text{n}=[fcnName argsChar]; % Insert the function call with the arguments

n=n+1;
text{n}=''; % Space

n=n+1;
text{n}='setappdata(gui,''isRunLog'',false);'; % Allow for user editing of the GUI again.

n=n+1;
text{n}=''; % Always end with a space

fid=fopen(logPath,'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);