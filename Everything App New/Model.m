classdef Model
    properties
        conn
    end

    methods (Static)

        

    end

    methods
        % Constructor
        function obj = Model(codeFolder)

            obj = Model();

            % 1. Connect to the SQL database.
            obj.conn = obj.connect_or_init_DB(codeFolder);
            
        end

        function conn = connect_or_init_DB(codeFolder)
            slash = filesep;
            try
                dbFile = getCommonPath();
            catch
                dbFolder = [codeFolder slash 'Databases'];
                if exist(dbFolder,'dir')~=7
                    mkdir(dbFolder);
                end
                dbFile = [dbFolder slash 'biomechOS.db'];
            end
            conn = DBSetup(dbFile, isDel);
        end

        

    end


end