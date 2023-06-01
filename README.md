# Biomech-Analysis-Platform
There are many software packages that perform various scientific data analyses, and many scientists write their own custom functions. However, there is no easy way for these custom functions or plethora of packages to interact with one another.

This "Biomechanical Analysis Platform" or "biomechOS" attempts to provide a common framework for data and code management that minimizes administrative requirements, while not imposing any method on the user. This framework will allow scientists greater ease of use when incorporating others' code, greater flexibility with their code, etc.

This app is currently written and tested entirely in base MATLAB R2021b, no toolboxes are required.

# Downloading & installing the app:
1. Download the latest release [here](https://github.com/biomechOS/Biomech-Analysis-Platform/releases/latest), or clone this repository to your computer.
2. Place the entire folder in your preferred location in your file system. 
3. Ensure that the folder is added to the MATLAB path ([see docs](https://www.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html)).

# A bit of the app's philosophy before going further:
This app utilizes the idea of abstract and instanced (aka "implemented") objects. Here, an "object" is the collection of metadata found in its JSON file. Both abstract and instanced versions of objects exist because all objects (variables/functions/function groups/other) can exist independently of their instantiations. This is because some metadata is always true regardless of the use case of an object (e.g. the general shape/type of a variable, the executable file associated with a function object, etc.). Abstract objects are noted with a 6 character hex code (e.g. "objectName_ABC123"). Instances ("implementations") of that object are noted with the same hex code, followed by a 3 character hex code (e.g. "objectName_ABC123_000"). In this way, multiple versions of the same abstract object can be tracked. This naming convention will be seen throughout the app, and in the names/contents of the JSON files.

# Opening the app:
1. When you first open the app, it will ask you to select a folder to place all future JSON settings files in. A suggested folder structure looks something like this:
-parent folder
|--folder with this repository in it (ex. name: biomechOS-repo)
|--folder to place all future JSON settings files in (ex. name: biomechOS-commonSettings)

# Creating a new project:
1. Click the "P+" button and provide a project name as a valid MATLAB variable name (spaces are ok, will be converted to underscores).
2. You will need to provide a project path and a data path by either pasting the paths into the text boxes, or clicking the buttons to the left of the text boxes to select a directory. A suggested folder structure looks something like this:
-parent folder
|--folder with this repository in it (ex. name: biomechOS-repo)
|--folder to place all future JSON settings files in (ex. name: biomechOS-commonSettings)
|--folder for an individual project (project path)
  |--"Raw Data Files" (this name must match exactly)
    |--subName1
      |--fileName1.ext
      |--fileNameN.ext (n'th file for this subject)
    |--subNameN (n'th subject's folder)
      |--fileName1
      |--fileNameN
3. After selecting a valid project and data path, the other tabs can be accessed.

# Importing metadata:
1. On the Import tab, click "L+" and provide a logsheet name as a valid MATLAB variable name (spaces are ok, will be converted to underscores).
2. Provide the path to a logsheet with valid MATLAB variable names as column headers, either by pasting the path into the text box or clicking "Set Logsheet Path" to the left of the text box.
3. If the logsheet is validly formatted, the variable names will automatically propagate from the column headers into the list box on the right. For each variable, specify using the drop down list whether it is "Subject" or "Trial" level (e.g. whether it is common to an entire subject, or specific to each individual trial). Also specify the variable type as "Double" or "Char".
4. On the left, specify the number of header rows (if data starts on row 4, then there are 3 header rows).
5. Next, specify in the drop down list the column header corresponding to the subjects' codenames.
6. Next, specify in the drop down list the column header corresponding to the trial names.
7. In the bottom left, click "S+" to add a specify trials. Click "Edit" to select which criteria to apply to which variables to isolate a subset of data.
8. Click "Run" to import the metadata.

# Processing data:
1. On the Process tab, in the middle column there is a label of the form "Default_XXXXXX_YYY". This is the processing function group created by default, and is the currently selected group. Processing functions and other processing function groups can be added to this group.
2. To create a new processing function group, click the "Groups" tab in the left column, and click the "G+" button. Enter a valid MATLAB variable name (spaces are ok, will be converted to underscores).
3. Click the "->" key to assign the highlighted group in the left column to the currently selected group in the middle column (whose name is indicated by the label above).
4. Click the "Sel" key to select a new group to work on.
5. Click the "<-" to unassign a group from the currently selected group in the middle column.
6. To create a new processing function, click the "Functions" tab in the left column, and click the "F+" button. Enter a valid MATLAB variable name (spaces are ok, will be converted to underscores).
7. Click the "->" key to assign the highlighted function in the left column to the currently selected group in the middle column (whose name is indicated by the label above).
8. Click the "<-" to unassign a function from the currently selected group in the middle column.
9. To create a new variable, click the "Variables" tab in the left column, and click the "V+" button. Enter a valid MATLAB variable name (spaces are ok, will be converted to underscores). See the "Creating function .m files" and "Adding variables to functions" sections for more details.

## Creating function .m files:
1. Right click on a function in the list in the left column (with a name of the form "TestFcn_XXXXXX"), and select "Open M File". If the file does not exist, you will be prompted for a name.
2. To change the name of an existing function, right click on the function in the list in the left column, and select "Open JSON". Change the value of the "MFileName" field in the JSON file. Don't forget to ensure that it matches the .m file exactly!

## Adding variables to functions:
1. After a function has an existing .m file associated with it, variables can be added. To do this, click on the "Function" tab in the middle column. This will allow you to edit the variables for the function highlighted in the middle column's "Group" tab.
2. In the function's .m file, highlight and copy the entire line that contains a "getArg" statement. In the "Function" tab, click the "+" button, and paste the getArg statement. Click OK. There is now a "getArg N" (where N is a number) in the middle column, and underneath it says "data". "data" is how a variable (assigned in a moment) is named in the function's .m file.
3. Repeat step 3 for the "setArg" line as well.
4. Select the "data" underneath the getArg. In the left column, in the "Variables" tab, select a variable. Click the "->" button to assign the variable (e.g. "var1_XXXXXX") to the current function. Now, you should see something like "data (var1_XXXXXX_YYY)" on that line. This indicates that the var1 variable is now assigned to this function, and is called "data" in that function.

## Running a function:
1. After all of the variables have been assigned to the function, select (click the checkbox for) the Specify Trials so that the function will operate only on a subset of the dataset.
2. On the "Groups" tab in the middle column, select the function to run. Click the "->" button to the right to add the highlighted function to the queue.
3. Click "Run" to run the function.