% SN_setTextInterpreter - recursively set the text interpreter for all
% graphical objects
%
% SN_setTextInterpreter(INTERPRETER) - recursively set the text INTERPRETER
% to the current figure. Usually the default interpreter for MATLAB is 
% 'TeX'. If the user wants 'LaTeX' interpreter, just use 
% SN_setTextInterpreter('LaTeX'); This works well after the figure is done
% plotting because all objects has been created. This is a good fix to
% MATLAB function SET(0,'defaultTextInterpreter','LaTeX') because the
% defaultTextInterpreter does not apply to legend in version 2014b.
%
% User can also use SN_setTextInterpreter(OBJ,INTERPRETER) to set text 
% INTERPRETER for a specific object and its children.
%
% @author: San Nguyen
% @date: 2014 10 15
%
