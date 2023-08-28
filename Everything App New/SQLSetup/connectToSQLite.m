function [conn] = connectToSQLite(dbFile,method)

%% PURPOSE: CONNECT TO SQLITE DATABASE USING EITHER THE BUILT-IN METHOD, OR JDBC DRIVER.
% Relevant pages:
% https://www.mathworks.com/products/database/driver-installation.html
% https://github.com/xerial/sqlite-jdbc
% https://www.mathworks.com/matlabcentral/answers/751729-how-to-extract-data-from-a-sqlite-database-with-null-values

if ~exist('method','var')
    method = 'DEFAULT';
else
    method = upper(method);
end

if isequal(method,'DEFAULT')
    mode = 'connect';
    if exist(dbFile,'file')~=2
        mode = 'create';
    end

    conn = sqlite(dbFile, mode);
end

if isequal(method,'JDBC')
    javac Sample.java;    
    if ispc
        java -classpath '.;sqlite-jdbc-3.42.0.1.jar'; % Windows
    else        
        java -classpath '.:sqlite-jdbc-3.42.0.1.jar'; % Mac
    end
end