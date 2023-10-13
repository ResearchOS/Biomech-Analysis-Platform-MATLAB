classdef Controller
    properties
        Model
        View
    end

    methods
        % Constructor
        function obj = Controller(codeFolder)
            obj.Model = Model(codeFolder);
            obj.View = View();
        end

        % Create new object
        function struct = createObject()



        end

    end


end