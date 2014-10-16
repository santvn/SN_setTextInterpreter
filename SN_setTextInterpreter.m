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

function SN_setTextInterpreter(obj,interpreter)
if exist('ax','var')
    if ~isobject(obj)
        obj = gcf;
        interpreter = obj;
    end
else
    obj = gcf;
end

if ~exist('interpreter','var')
    interpreter = get(0,'DefaultTextInterpreter');
end
setInterpreter(obj,interpreter);
end

% recursively set all objects under ax
function setInterpreter(ax,interpreter)
    if isempty(ax)
        return;
    end
    
    if iscell(ax)
        for i = 1:numel(ax)
            setInterpreter(ax{i},interpreter);
        end
        return;
    end
    
    if ~isobject(ax)
        return;
    end
    if numel(ax)>1
        for i = 1:numel(ax)
            setInterpreter(ax(i),interpreter);
        end
        return;
    end
    prop = properties(ax);
    
    if isprop(ax,'Interpreter')
        set(ax,'Interpreter',interpreter);
    end
    if isprop(ax,'TickLabelInterpreter')
        set(ax,'TickLabelInterpreter',interpreter)
    end
    % go through all properties to get the children text to set interpreter
    for i = 1:numel(prop)
        % advoiding an infinite recursion
        if strcmpi(prop{i},'parent');
            continue;
        end
        
        % advoiding an infinite recursion of refering to the same object
        % again and again
        if strncmpi(prop{i},'current',7);
            continue;
        end
        
        propDetails = get(ax,prop{i});
        if iscell(propDetails)
            for j = 1:numel(propDetails)
                if isobject(propDetails{j})
                    setInterpreter(propDetails{j},interpreter);
                end
            end
            return
        end
        if isobject(propDetails)
            for j = 1:numel(propDetails)
                setInterpreter(propDetails(j),interpreter);
            end
        end
    end
end
