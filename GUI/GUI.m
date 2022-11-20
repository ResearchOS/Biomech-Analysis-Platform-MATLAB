classdef GUI < uifigure & handle
    properties
        version = '3.1.0'; % The current version of the GUI
    end
    methods
        function obj = GUI()
            obj = pgui; % Construct the whole object.
        end
    end
end