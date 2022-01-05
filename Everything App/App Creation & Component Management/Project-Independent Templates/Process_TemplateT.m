function [dataOut]=Process_TemplateT(methodLetter,subName,trialName,varargin)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER TRIAL.
% Inputs:
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% subName: The subject name (char)
% trialName: The trial name (char)

%% Do Not Edit. Setup Before Running.
if nargin==0
    dataOut='T'; % Indicates trial level function
    return;
end

%% TODO: Store the structure path to the output variable.
% dataOut{m,n}, where
% m=argument number, and
% n=1 indicates the path name, and 
% n=2 indicates the actual data
dataOut{1,1}=['projectStruct.' subName '.' trialName '.Results.Mocap.Cardinal.TBCMVelocAngle.Method1' methodLetter]; % Example

if nargin==3 % Indicates to only return the variable path names
    return;
end

%% TODO: Assign input arguments to variable names
startFrame=varargin{1}; % Frame to start processing
endFrame=varargin{2}; % Frame to end processing
tbcmVeloc=varargin{3}; % The TBCM velocity vector
initDur=varargin{4}; % The duration over which to check the initial direction of travel.
initDir=varargin{5}; % Standard initial direction of travel

%% TODO: Biomechanical operations for single trial.        
% Code here.
tLength=length(tbcmVeloc);
tbcmAngle=NaN(tLength,1);
vert=[0 0 1];
if mean(tbcmVeloc(startFrame:startFrame+initDur,2,'omitnan')>0)
    startSouth=1;
else
    startSouth=0;
end
if startSouth==1
    v2=initDir; % Walking North from South
else
    v2=-1*initDir; % Walking South from North
end
for i=startFrame:endFrame
    x=cross([tbcmVeloc(i,:) 0],v2);
    c=sign(dot(x,vert))*norm(x);
    tbcmAngle(i)=atan2d(c,dot([tbcmVeloc(i,:) 0],v2));
end

%% TODO: Store the computed variable(s) data to the output variable.
% dataOut{m,n}, where
% m=argument number, and
% n=1 indicates the path name, and 
% n=2 indicates the actual data
dataOut{1,2}=tbcmAngle;