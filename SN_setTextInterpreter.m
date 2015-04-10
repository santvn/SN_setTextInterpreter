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
if exist('obj','var')
    if ~isobject(obj)
        if verLessThan('matlab','8.4')
            if ~isa(obj, 'double')
                interpreter = obj;
                obj = gcf;
            end
        else
            interpreter = obj;
            obj = gcf;
        end       
    end
else
    obj = gcf;
end

if ~exist('interpreter','var')
    interpreter = get(0,'DefaultTextInterpreter');
end

if ~ischar(interpreter)
    error('MATLAB:SN_setTextInterpreter:InterNotText','Interpreter must be a string');
elseif sum(strcmpi(interpreter,{'latex','tex','none'}))<1
    error('MATLAB:SN_setTextInterpreter:InterNotText','Interpreter must be either latex, tex, or none.');
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
    
    if ~isobject(ax) && ~verLessThan('matlab','8.4')
        return;
    end
    if numel(ax)>1
        for i = 1:numel(ax)
            setInterpreter(ax(i),interpreter);
        end
        return;
    end
    
    if isprop(ax,'Interpreter')
        set(ax,'Interpreter',interpreter);
    end
    if isprop(ax,'TickLabelInterpreter')
        set(ax,'TickLabelInterpreter',interpreter)
    end
    if isprop(ax,'type')
        type = get(ax,'type');
        if strncmpi(type(end-3:end),'menu',4);
            return;
        end
        if sum(strcmpi(type,{'line','patch'}))>0;
            return;
        end
        if strncmpi(type(end-3:end),'tool',4);
            return;
        end
    end
    
    if verLessThan('matlab','8.4') && isa(ax, 'double')
        if ax ~= 0
            ax = handle(ax);
            if isgraphics(ax)
                if ~graphicsversion(ax,'handlegraphics')
                    mc = metaclass(ax);
                    prop = mc.PropertyList;
                    prop = {prop.Name};
                else
                    prop = fieldnames(ax);
                end

            else
                prop = {};
            end
        else
            prop = {};
        end
    else
        prop = properties(ax);
    end
    
    % go through all properties to get the children text to set interpreter
    for i = 1:numel(prop)
        % advoiding an infinite recursion
        if strcmpi(prop{i},'parent');
            continue;
        end
        
        if strcmpi(prop{i},'FigureHandle');
            continue;
        end
        
        if strcmpi(prop{i},'WindowButtonDownFcn');
            continue;
        end
        
        % advoiding an infinite recursion of refering to the same object
        % again and again
        if strncmpi(prop{i},'current',7);
            continue;
        end
        
        if strncmpi(prop{i}(end-2:end),'fcn',3);
            continue;
        end
        
        if numel(prop{i})>5 && strncmpi(prop{i}(end-5:end),'object',6);
            continue;
        end
        
        if numel(prop{i})>8 && strncmpi(prop{i}(end-8:end),'ticklabel',9);
            continue;
        end
        
        if verLessThan('matlab','8.4')
            if (numel(prop{i})>4 && strncmpi(prop{i}(end-4:end),'label',3)) ||...
                    strcmpi(prop{i},'children') || ...
                    strcmpi(prop{i},'title');
                propDetails = get(ax,prop{i});
            else
                continue;
            end
        else
                propDetails = get(ax,prop{i});
        end
                        
        if iscell(propDetails)
            for j = 1:numel(propDetails)
                if isobject(propDetails{j}) || verLessThan('matlab','8.4')
                    setInterpreter(propDetails{j},interpreter);
                end
            end
            continue
        end
        if isobject(propDetails) || verLessThan('matlab','8.4')
            for j = 1:numel(propDetails)
                setInterpreter(propDetails(j),interpreter);
            end
            continue
        end
    end
end
