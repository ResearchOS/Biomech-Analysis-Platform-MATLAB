function [bool] = isDoubleClick(obj)

%% PURPOSE: DETERMINE IF A CLICK IS A DOUBLE CLICK. THIS IS A LOW PRIORITY.

persistent count prevTime;

if isempty(count)
    count=0;
end

if isempty(prevTime)
    prevTime = datetime('now');
    currTime = prevTime;
    bool = false;
    return;
else
    currTime = datetime('now');
end

count=count+1;

tol = seconds(0.5);

bool = false;
if currTime - prevTime < tol && count>1
    bool = true;
else
    count = 0;
end