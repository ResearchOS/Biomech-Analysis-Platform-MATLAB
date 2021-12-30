function []=fcnNamesButtonPushed(src)

%% PURPOSE: OPEN (NOT CREATE) THE FUNCTION NAME ON THE BUTTON

fcnName=src.Text;

edit(fcnName);