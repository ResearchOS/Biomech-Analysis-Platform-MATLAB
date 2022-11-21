classdef GUI < handle
    properties (SetAccess = immutable) % Cannot be changed ever.
        version = '3.1.0'; % The current version of the GUI
    end
    properties (SetAccess = public) % Publicly available to read and write
        handle = []; % The handle to the PGUI figure  
        handles = []; % The handles to all GUI components   
    end
    methods
        function obj = GUI()
            obj.handle = uifigure('Name','pgui',...
                'Visible','on','Resize','on','AutoResizeChildren','off',...
                'SizeChangedFcn',@appResize);
            fig=obj.handle;
            set(fig,'DeleteFcn',@(fig, event) saveGUIState(fig));

            obj.handles=initializeComponents(obj);
        end
    end
end