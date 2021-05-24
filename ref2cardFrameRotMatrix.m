function [refFrameRotMatrix]=ref2cardFrameRotMatrix(cardinalFrame,oldFrame)

%% Converts any unit orthonormal reference frame that is orthonormal to the cardinal reference frame,
%% to the specified cardinal reference frame. Works with importSettings[Project].m

% If the room isn't perfectly aligned with the cardinal directions, just
% pick a direction orthogonal to the walls that most closely (<45 degrees)
% tracks to cardinal directions.
% In the EAS 103 room, the cardinal directions are as follows in the room:
% Perpendicular line from room center to wall with door, ramp, & shelf: North
% Perpendicular line from room center to wall with shelf & command center: East
% Perpendicular line from room center to wall with windows looking out over 5th St.: South
% Perpendicular line from room center to wall with windows looking out on Hudson St.: West
cardX=[1 0 0]; % Aligned with "East" (cardinalFrame.PosX).
cardY=[0 1 0]; % Aligned with "North" (cardinalFrame.PosY).
cardZ=[0 0 1]; % Aligned with "Up" (cardinalFrame.PosZ).

if isequal(oldFrame.RHandRule,'Yes')
    
    % This is the (old) local reference frame.
    posXDir=oldFrame.PosX;
    posYDir=oldFrame.PosY;
    posZDir=oldFrame.PosZ;
    
    % Trying dynamic cardinal direction code here.
    % If both reference frames are entirely given in cardinal direction strings.
    if ischar(posXDir) && ischar(posYDir) && ischar(posZDir) && ...
            ischar(cardinalFrame.PosX) && ischar(cardinalFrame.PosY) && ischar(cardinalFrame.PosZ)
        
        if isequal(cardinalFrame.PosX,'E') % X East
            if isequal(cardinalFrame.PosY,'N') % X East Y North
                switch posXDir
                    case 'E'
                        oldX=[1 0 0];
                    case 'S'
                        oldX=[0 -1 0];
                    case 'W'
                        oldX=[-1 0 0];
                    case 'N'
                        oldX=[0 1 0];
                    case 'Up'
                        oldX=[0 0 1];
                    case 'Down'
                        oldX=[0 0 -1];
                end
                switch posYDir
                    case 'E'
                        oldY=[1 0 0];
                    case 'S'
                        oldY=[0 -1 0];
                    case 'W'
                        oldY=[-1 0 0];
                    case 'N'
                        oldY=[0 1 0];
                    case 'Up'
                        oldY=[0 0 1];
                    case 'Down'
                        oldY=[0 0 -1];
                end
                switch posZDir
                    case 'E'
                        oldZ=[1 0 0];
                    case 'S'
                        oldZ=[0 -1 0];
                    case 'W'
                        oldZ=[-1 0 0];
                    case 'N'
                        oldZ=[0 1 0];
                    case 'Up'
                        oldZ=[0 0 1];
                    case 'Down'
                        oldZ=[0 0 -1];
                end
            elseif isequal(cardinalFrame.PosY,'S') % X East Y South
                switch posXDir
                    case 'E'
                        oldX=[1 0 0];
                    case 'S'
                        oldX=[0 1 0];
                    case 'W'
                        oldX=[-1 0 0];
                    case 'N'
                        oldX=[0 -1 0];
                    case 'Up'
                        oldX=[0 0 -1];
                    case 'Down'
                        oldX=[0 0 1];
                end
                switch posYDir
                    case 'E'
                        oldY=[1 0 0];
                    case 'S'
                        oldY=[0 1 0];
                    case 'W'
                        oldY=[-1 0 0];
                    case 'N'
                        oldY=[0 -1 0];
                    case 'Up'
                        oldY=[0 0 -1];
                    case 'Down'
                        oldY=[0 0 1];
                end
                switch posZDir
                    case 'E'
                        oldZ=[1 0 0];
                    case 'S'
                        oldZ=[0 1 0];
                    case 'W'
                        oldZ=[-1 0 0];
                    case 'N'
                        oldZ=[0 -1 0];
                    case 'Up'
                        oldZ=[0 0 -1];
                    case 'Down'
                        oldZ=[0 0 1];
                end
            elseif isequal(cardinalFrame.PosY,'Up') % X East Y Up
                switch posXDir
                    case 'E'
                        oldX=[1 0 0];
                    case 'S'
                        oldX=[0 0 1];
                    case 'W'
                        oldX=[-1 0 0];
                    case 'N'
                        oldX=[0 0 -1];
                    case 'Up'
                        oldX=[0 1 0];
                    case 'Down'
                        oldX=[0 -1 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[1 0 0];
                    case 'S'
                        oldY=[0 0 1];
                    case 'W'
                        oldY=[-1 0 0];
                    case 'N'
                        oldY=[0 0 -1];
                    case 'Up'
                        oldY=[0 1 0];
                    case 'Down'
                        oldY=[0 -1 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[1 0 0];
                    case 'S'
                        oldZ=[0 0 1];
                    case 'W'
                        oldZ=[-1 0 0];
                    case 'N'
                        oldZ=[0 0 -1];
                    case 'Up'
                        oldZ=[0 1 0];
                    case 'Down'
                        oldZ=[0 -1 0];
                end
            elseif isequal(cardinalFrame.PosY,'Down') % X East Y Down
                switch posXDir
                    case 'E'
                        oldX=[1 0 0];
                    case 'S'
                        oldX=[0 0 -1];
                    case 'W'
                        oldX=[-1 0 0];
                    case 'N'
                        oldX=[0 0 1];
                    case 'Up'
                        oldX=[0 -1 0];
                    case 'Down'
                        oldX=[0 1 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[1 0 0];
                    case 'S'
                        oldY=[0 0 -1];
                    case 'W'
                        oldY=[-1 0 0];
                    case 'N'
                        oldY=[0 0 1];
                    case 'Up'
                        oldY=[0 -1 0];
                    case 'Down'
                        oldY=[0 1 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[1 0 0];
                    case 'S'
                        oldZ=[0 0 -1];
                    case 'W'
                        oldZ=[-1 0 0];
                    case 'N'
                        oldZ=[0 0 1];
                    case 'Up'
                        oldZ=[0 -1 0];
                    case 'Down'
                        oldZ=[0 1 0];
                end
            end
        elseif isequal(cardinalFrame.PosX,'S') % X South
            if isequal(cardinalFrame.PosY,'E') % X South Y East
                switch posXDir
                    case 'E'
                        oldX=[0 1 0];
                    case 'S'
                        oldX=[1 0 0];
                    case 'W'
                        oldX=[0 -1 0];
                    case 'N'
                        oldX=[0 -1 0];
                    case 'Up'
                        oldX=[0 0 1];
                    case 'Down'
                        oldX=[0 0 -1];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 1 0];
                    case 'S'
                        oldY=[1 0 0];
                    case 'W'
                        oldY=[0 -1 0];
                    case 'N'
                        oldY=[0 -1 0];
                    case 'Up'
                        oldY=[0 0 1];
                    case 'Down'
                        oldY=[0 0 -1];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 1 0];
                    case 'S'
                        oldZ=[1 0 0];
                    case 'W'
                        oldZ=[0 -1 0];
                    case 'N'
                        oldZ=[0 -1 0];
                    case 'Up'
                        oldZ=[0 0 1];
                    case 'Down'
                        oldZ=[0 0 -1];
                end
            elseif isequal(cardinalFrame.PosY,'W') % X South Y West
                switch posXDir
                    case 'E'
                        oldX=[-1 0 0];
                    case 'S'
                        oldX=[1 0 0];
                    case 'W'
                        oldX=[1 0 0];
                    case 'N'
                        oldX=[-1 0 0];
                    case 'Up'
                        oldX=[0 0 -1];
                    case 'Down'
                        oldX=[0 0 1];
                end
                switch posYDir
                    case 'E'
                        oldY=[-1 0 0];
                    case 'S'
                        oldY=[1 0 0];
                    case 'W'
                        oldY=[1 0 0];
                    case 'N'
                        oldY=[-1 0 0];
                    case 'Up'
                        oldY=[0 0 -1];
                    case 'Down'
                        oldY=[0 0 1];
                end
                switch posZDir
                    case 'E'
                        oldZ=[-1 0 0];
                    case 'S'
                        oldZ=[1 0 0];
                    case 'W'
                        oldZ=[1 0 0];
                    case 'N'
                        oldZ=[-1 0 0];
                    case 'Up'
                        oldZ=[0 0 -1];
                    case 'Down'
                        oldZ=[0 0 1];
                end
            elseif isequal(cardinalFrame.PosY,'Up') % X South Y Up
                switch posXDir
                    case 'E'
                        oldX=[0 0 -1];
                    case 'S'
                        oldX=[1 0 0];
                    case 'W'
                        oldX=[0 0 1];
                    case 'N'
                        oldX=[-1 0 0];
                    case 'Up'
                        oldX=[0 1 0];
                    case 'Down'
                        oldX=[0 -1 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 0 -1];
                    case 'S'
                        oldY=[1 0 0];
                    case 'W'
                        oldY=[0 0 1];
                    case 'N'
                        oldY=[-1 0 0];
                    case 'Up'
                        oldY=[0 1 0];
                    case 'Down'
                        oldY=[0 -1 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 0 -1];
                    case 'S'
                        oldZ=[1 0 0];
                    case 'W'
                        oldZ=[0 0 1];
                    case 'N'
                        oldZ=[-1 0 0];
                    case 'Up'
                        oldZ=[0 1 0];
                    case 'Down'
                        oldZ=[0 -1 0];
                end
            elseif isequal(cardinalFrame.PosY,'Down') % X South Y Down
                switch posXDir
                    case 'E'
                        oldX=[0 0 1];
                    case 'S'
                        oldX=[1 0 0];
                    case 'W'
                        oldX=[0 0 -1];
                    case 'N'
                        oldX=[-1 0 0];
                    case 'Up'
                        oldX=[0 -1 0];
                    case 'Down'
                        oldX=[0 1 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 0 1];
                    case 'S'
                        oldY=[1 0 0];
                    case 'W'
                        oldY=[0 0 -1];
                    case 'N'
                        oldY=[-1 0 0];
                    case 'Up'
                        oldY=[0 -1 0];
                    case 'Down'
                        oldY=[0 1 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 0 1];
                    case 'S'
                        oldZ=[1 0 0];
                    case 'W'
                        oldZ=[0 0 -1];
                    case 'N'
                        oldZ=[-1 0 0];
                    case 'Up'
                        oldZ=[0 -1 0];
                    case 'Down'
                        oldZ=[0 1 0];
                end
            end
        elseif isequal(cardinalFrame.PosX,'W') % X West
            if isequal(cardinalFrame.PosY,'S') % X West Y South
                switch posXDir
                    case 'E'
                        oldX=[-1 0 0];
                    case 'S'
                        oldX=[0 1 0];
                    case 'W'
                        oldX=[1 0 0];
                    case 'N'
                        oldX=[0 -1 0];
                    case 'Up'
                        oldX=[0 0 1];
                    case 'Down'
                        oldX=[0 0 -1];
                end
                switch posYDir
                    case 'E'
                        oldY=[-1 0 0];
                    case 'S'
                        oldY=[0 1 0];
                    case 'W'
                        oldY=[1 0 0];
                    case 'N'
                        oldY=[0 -1 0];
                    case 'Up'
                        oldY=[0 0 1];
                    case 'Down'
                        oldY=[0 0 -1];
                end
                switch posZDir
                    case 'E'
                        oldZ=[-1 0 0];
                    case 'S'
                        oldZ=[0 1 0];
                    case 'W'
                        oldZ=[1 0 0];
                    case 'N'
                        oldZ=[0 -1 0];
                    case 'Up'
                        oldZ=[0 0 1];
                    case 'Down'
                        oldZ=[0 0 -1];
                end
            elseif isequal(cardinalFrame.PosY,'N') % X West Y North
                switch posXDir
                    case 'E'
                        oldX=[-1 0 0];
                    case 'S'
                        oldX=[0 -1 0];
                    case 'W'
                        oldX=[1 0 0];
                    case 'N'
                        oldX=[0 1 0];
                    case 'Up'
                        oldX=[0 0 -1];
                    case 'Down'
                        oldX=[0 0 1];
                end
                switch posYDir
                    case 'E'
                        oldY=[-1 0 0];
                    case 'S'
                        oldY=[0 -1 0];
                    case 'W'
                        oldY=[1 0 0];
                    case 'N'
                        oldY=[0 1 0];
                    case 'Up'
                        oldY=[0 0 -1];
                    case 'Down'
                        oldY=[0 0 1];
                end
                switch posZDir
                    case 'E'
                        oldZ=[-1 0 0];
                    case 'S'
                        oldZ=[0 -1 0];
                    case 'W'
                        oldZ=[1 0 0];
                    case 'N'
                        oldZ=[0 1 0];
                    case 'Up'
                        oldZ=[0 0 -1];
                    case 'Down'
                        oldZ=[0 0 1];
                end
            elseif isequal(cardinalFrame.PosY,'Up') % X West Y Up
                switch posXDir
                    case 'E'
                        oldX=[-1 0 0];
                    case 'S'
                        oldX=[0 0 -1];
                    case 'W'
                        oldX=[1 0 0];
                    case 'N'
                        oldX=[0 0 1];
                    case 'Up'
                        oldX=[0 1 0];
                    case 'Down'
                        oldX=[0 -1 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[-1 0 0];
                    case 'S'
                        oldY=[0 0 -1];
                    case 'W'
                        oldY=[1 0 0];
                    case 'N'
                        oldY=[0 0 1];
                    case 'Up'
                        oldY=[0 1 0];
                    case 'Down'
                        oldY=[0 -1 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[-1 0 0];
                    case 'S'
                        oldZ=[0 0 -1];
                    case 'W'
                        oldZ=[1 0 0];
                    case 'N'
                        oldZ=[0 0 1];
                    case 'Up'
                        oldZ=[0 1 0];
                    case 'Down'
                        oldZ=[0 -1 0];
                end
            elseif isequal(cardinalFrame.PosY,'Down')% X West Y Down
                switch posXDir
                    case 'E'
                        oldX=[-1 0 0];
                    case 'S'
                        oldX=[0 0 1];
                    case 'W'
                        oldX=[1 0 0];
                    case 'N'
                        oldX=[0 0 -1];
                    case 'Up'
                        oldX=[0 -1 0];
                    case 'Down'
                        oldX=[0 1 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[-1 0 0];
                    case 'S'
                        oldY=[0 0 1];
                    case 'W'
                        oldY=[1 0 0];
                    case 'N'
                        oldY=[0 0 -1];
                    case 'Up'
                        oldY=[0 -1 0];
                    case 'Down'
                        oldY=[0 1 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[-1 0 0];
                    case 'S'
                        oldZ=[0 0 1];
                    case 'W'
                        oldZ=[1 0 0];
                    case 'N'
                        oldZ=[0 0 -1];
                    case 'Up'
                        oldZ=[0 -1 0];
                    case 'Down'
                        oldZ=[0 1 0];
                end
            end
        elseif isequal(cardinalFrame.PosX,'N') % X North
            if isequal(cardinalFrame.PosY,'E') % X North Y East
                switch posXDir
                    case 'E'
                        oldX=[0 1 0];
                    case 'S'
                        oldX=[-1 0 0];
                    case 'W'
                        oldX=[0 -1 0];
                    case 'N'
                        oldX=[1 0 0];
                    case 'Up'
                        oldX=[0 0 -1];
                    case 'Down'
                        oldX=[0 0 1];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 1 0];
                    case 'S'
                        oldY=[-1 0 0];
                    case 'W'
                        oldY=[0 -1 0];
                    case 'N'
                        oldY=[1 0 0];
                    case 'Up'
                        oldY=[0 0 -1];
                    case 'Down'
                        oldY=[0 0 1];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 1 0];
                    case 'S'
                        oldZ=[-1 0 0];
                    case 'W'
                        oldZ=[0 -1 0];
                    case 'N'
                        oldZ=[1 0 0];
                    case 'Up'
                        oldZ=[0 0 -1];
                    case 'Down'
                        oldZ=[0 0 1];
                end
            elseif isequal(cardinalFrame.PosY,'W') % X North Y West
                switch posXDir
                    case 'E'
                        oldX=[0 -1 0];
                    case 'S'
                        oldX=[-1 0 0];
                    case 'W'
                        oldX=[0 1 0];
                    case 'N'
                        oldX=[1 0 0];
                    case 'Up'
                        oldX=[0 0 1];
                    case 'Down'
                        oldX=[0 0 -1];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 -1 0];
                    case 'S'
                        oldY=[-1 0 0];
                    case 'W'
                        oldY=[0 1 0];
                    case 'N'
                        oldY=[1 0 0];
                    case 'Up'
                        oldY=[0 0 1];
                    case 'Down'
                        oldY=[0 0 -1];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 -1 0];
                    case 'S'
                        oldZ=[-1 0 0];
                    case 'W'
                        oldZ=[0 1 0];
                    case 'N'
                        oldZ=[1 0 0];
                    case 'Up'
                        oldZ=[0 0 1];
                    case 'Down'
                        oldZ=[0 0 -1];
                end
            elseif isequal(cardinalFrame.PosY,'Up') % X North Y Up
                switch posXDir
                    case 'E'
                        oldX=[0 0 1];
                    case 'S'
                        oldX=[-1 0 0];
                    case 'W'
                        oldX=[0 0 -1];
                    case 'N'
                        oldX=[1 0 0];
                    case 'Up'
                        oldX=[0 1 0];
                    case 'Down'
                        oldX=[0 -1 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 0 1];
                    case 'S'
                        oldY=[-1 0 0];
                    case 'W'
                        oldY=[0 0 -1];
                    case 'N'
                        oldY=[1 0 0];
                    case 'Up'
                        oldY=[0 1 0];
                    case 'Down'
                        oldY=[0 -1 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 0 1];
                    case 'S'
                        oldZ=[-1 0 0];
                    case 'W'
                        oldZ=[0 0 -1];
                    case 'N'
                        oldZ=[1 0 0];
                    case 'Up'
                        oldZ=[0 1 0];
                    case 'Down'
                        oldZ=[0 -1 0];
                end
            elseif isequal(cardinalFrame.PosY,'Down') % X North Y Down
                switch posXDir
                    case 'E'
                        oldX=[0 0 -1];
                    case 'S'
                        oldX=[-1 0 0];
                    case 'W'
                        oldX=[0 0 1];
                    case 'N'
                        oldX=[1 0 0];
                    case 'Up'
                        oldX=[0 0 -1];
                    case 'Down'
                        oldX=[0 0 1];
                end
            end
        elseif isequal(cardinalFrame.PosX,'Up') % X Up
            if isequal(cardinalFrame.PosY,'E') % X Up Y East
                switch posXDir
                    case 'E'
                        oldX=[0 1 0];
                    case 'S'
                        oldX=[0 0 -1];
                    case 'W'
                        oldX=[0 -1 0];
                    case 'N'
                        oldX=[0 0 1];
                    case 'Up'
                        oldX=[1 0 0];
                    case 'Down'
                        oldX=[-1 0 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 1 0];
                    case 'S'
                        oldY=[0 0 -1];
                    case 'W'
                        oldY=[0 -1 0];
                    case 'N'
                        oldY=[0 0 1];
                    case 'Up'
                        oldY=[1 0 0];
                    case 'Down'
                        oldY=[-1 0 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 1 0];
                    case 'S'
                        oldZ=[0 0 -1];
                    case 'W'
                        oldZ=[0 -1 0];
                    case 'N'
                        oldZ=[0 0 1];
                    case 'Up'
                        oldZ=[1 0 0];
                    case 'Down'
                        oldZ=[-1 0 0];
                end
            elseif isequal(cardinalFrame.PosY,'W') % X Up Y West
                switch posXDir
                    case 'E'
                        oldX=[0 -1 0];
                    case 'S'
                        oldX=[0 0 1];
                    case 'W'
                        oldX=[0 1 0];
                    case 'N'
                        oldX=[0 0 -1];
                    case 'Up'
                        oldX=[1 0 0];
                    case 'Down'
                        oldX=[-1 0 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 -1 0];
                    case 'S'
                        oldY=[0 0 1];
                    case 'W'
                        oldY=[0 1 0];
                    case 'N'
                        oldY=[0 0 -1];
                    case 'Up'
                        oldY=[1 0 0];
                    case 'Down'
                        oldY=[-1 0 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 -1 0];
                    case 'S'
                        oldZ=[0 0 1];
                    case 'W'
                        oldZ=[0 1 0];
                    case 'N'
                        oldZ=[0 0 -1];
                    case 'Up'
                        oldZ=[1 0 0];
                    case 'Down'
                        oldZ=[-1 0 0];
                end
            elseif isequal(cardinalFrame.PosY,'W') % X Up Y North
                switch posXDir
                    case 'E'
                        oldX=[0 0 -1];
                    case 'S'
                        oldX=[0 -1 0];
                    case 'W'
                        oldX=[0 0 1];
                    case 'N'
                        oldX=[0 1 0];
                    case 'Up'
                        oldX=[1 0 0];
                    case 'Down'
                        oldX=[-1 0 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 0 -1];
                    case 'S'
                        oldY=[0 -1 0];
                    case 'W'
                        oldY=[0 0 1];
                    case 'N'
                        oldY=[0 1 0];
                    case 'Up'
                        oldY=[1 0 0];
                    case 'Down'
                        oldY=[-1 0 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 0 -1];
                    case 'S'
                        oldZ=[0 -1 0];
                    case 'W'
                        oldZ=[0 0 1];
                    case 'N'
                        oldZ=[0 1 0];
                    case 'Up'
                        oldZ=[1 0 0];
                    case 'Down'
                        oldZ=[-1 0 0];
                end
            elseif isequal(cardinalFrame.PosY,'W') % X Up Y South
                switch posXDir
                    case 'E'
                        oldX=[0 0 1];
                    case 'S'
                        oldX=[0 1 0];
                    case 'W'
                        oldX=[0 0 -1];
                    case 'N'
                        oldX=[0 -1 0];
                    case 'Up'
                        oldX=[1 0 0];
                    case 'Down'
                        oldX=[-1 0 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 0 1];
                    case 'S'
                        oldY=[0 1 0];
                    case 'W'
                        oldY=[0 0 -1];
                    case 'N'
                        oldY=[0 -1 0];
                    case 'Up'
                        oldY=[1 0 0];
                    case 'Down'
                        oldY=[-1 0 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 0 1];
                    case 'S'
                        oldZ=[0 1 0];
                    case 'W'
                        oldZ=[0 0 -1];
                    case 'N'
                        oldZ=[0 -1 0];
                    case 'Up'
                        oldZ=[1 0 0];
                    case 'Down'
                        oldZ=[-1 0 0];
                end
            end
        elseif isequal(cardinalFrame.PosX,'Down') % X Down
            if isequal(cardinalFrame.PosY,'E') % X Down Y East
                switch posXDir
                    case 'E'
                        oldX=[0 1 0];
                    case 'S'
                        oldX=[0 0 1];
                    case 'W'
                        oldX=[0 -1 0];
                    case 'N'
                        oldX=[0 0 -1];
                    case 'Up'
                        oldX=[-1 0 0];
                    case 'Down'
                        oldX=[1 0 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 1 0];
                    case 'S'
                        oldY=[0 0 1];
                    case 'W'
                        oldY=[0 -1 0];
                    case 'N'
                        oldY=[0 0 -1];
                    case 'Up'
                        oldY=[-1 0 0];
                    case 'Down'
                        oldY=[1 0 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 1 0];
                    case 'S'
                        oldZ=[0 0 1];
                    case 'W'
                        oldZ=[0 -1 0];
                    case 'N'
                        oldZ=[0 0 -1];
                    case 'Up'
                        oldZ=[-1 0 0];
                    case 'Down'
                        oldZ=[1 0 0];
                end
            elseif isequal(cardinalFrame.PosY,'E') % X Down Y West
                switch posXDir
                    case 'E'
                        oldX=[0 -1 0];
                    case 'S'
                        oldX=[0 0 -1];
                    case 'W'
                        oldX=[0 1 0];
                    case 'N'
                        oldX=[0 0 1];
                    case 'Up'
                        oldX=[-1 0 0];
                    case 'Down'
                        oldX=[1 0 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 -1 0];
                    case 'S'
                        oldY=[0 0 -1];
                    case 'W'
                        oldY=[0 1 0];
                    case 'N'
                        oldY=[0 0 1];
                    case 'Up'
                        oldY=[-1 0 0];
                    case 'Down'
                        oldY=[1 0 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 -1 0];
                    case 'S'
                        oldZ=[0 0 -1];
                    case 'W'
                        oldZ=[0 1 0];
                    case 'N'
                        oldZ=[0 0 1];
                    case 'Up'
                        oldZ=[-1 0 0];
                    case 'Down'
                        oldZ=[1 0 0];
                end
            elseif isequal(cardinalFrame.PosY,'E') % X Down Y North
                switch posXDir
                    case 'E'
                        oldX=[0 0 1];
                    case 'S'
                        oldX=[0 -1 0];
                    case 'W'
                        oldX=[0 0 -1];
                    case 'N'
                        oldX=[0 1 0];
                    case 'Up'
                        oldX=[-1 0 0];
                    case 'Down'
                        oldX=[1 0 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 0 1];
                    case 'S'
                        oldY=[0 -1 0];
                    case 'W'
                        oldY=[0 0 -1];
                    case 'N'
                        oldY=[0 1 0];
                    case 'Up'
                        oldY=[-1 0 0];
                    case 'Down'
                        oldY=[1 0 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 0 1];
                    case 'S'
                        oldZ=[0 -1 0];
                    case 'W'
                        oldZ=[0 0 -1];
                    case 'N'
                        oldZ=[0 1 0];
                    case 'Up'
                        oldZ=[-1 0 0];
                    case 'Down'
                        oldZ=[1 0 0];
                end
            elseif isequal(cardinalFrame.PosY,'E') % X Down Y South
                switch posXDir
                    case 'E'
                        oldX=[0 0 -1];
                    case 'S'
                        oldX=[0 1 0];
                    case 'W'
                        oldX=[0 0 1];
                    case 'N'
                        oldX=[0 -1 0];
                    case 'Up'
                        oldX=[-1 0 0];
                    case 'Down'
                        oldX=[1 0 0];
                end
                switch posYDir
                    case 'E'
                        oldY=[0 0 -1];
                    case 'S'
                        oldY=[0 1 0];
                    case 'W'
                        oldY=[0 0 1];
                    case 'N'
                        oldY=[0 -1 0];
                    case 'Up'
                        oldY=[-1 0 0];
                    case 'Down'
                        oldY=[1 0 0];
                end
                switch posZDir
                    case 'E'
                        oldZ=[0 0 -1];
                    case 'S'
                        oldZ=[0 1 0];
                    case 'W'
                        oldZ=[0 0 1];
                    case 'N'
                        oldZ=[0 -1 0];
                    case 'Up'
                        oldZ=[-1 0 0];
                    case 'Down'
                        oldZ=[1 0 0];
                end
            end
        end
    end    
    
    % I think this is the proper formula.
    refFrameRotMatrix=[dot(cardX,oldX) dot(cardX,oldY) dot(cardX,oldZ); dot(cardY,oldX) dot(cardY,oldY) dot(cardY,oldZ); dot(cardZ,oldX) dot(cardZ,oldY) dot(cardZ,oldZ)];
    
else
    error('Reference frame does not follow the right hand rule.');
end

end