classdef DataObject < dynamicprops
    % -------------------------------------------------------------------------%
    % Special object used to store data and pass it around. It first takes
    % whatever data you want to pass in as an input, but you can also add or
    % remove data as you'd like. All data are public, so you can access
    % individual data stored just by calling your object.dataYouWant
    %
    %
    % Usage: data = dataObject('var1','var2','var3'), always takes strings
    % Written 26Jul2019 KS
    % Updated 27Jul2019 KS Better handling of inputs and refactored
    %                      message printer
    %         31Jul2019 KS Added functionality for variable input types and
    %                      new output options
    % -------------------------------------------------------------------------%
    
    properties (Access = protected)
        dynamicproperties
    end
    
    methods
        function obj = DataObject(varargin)
            if nargin == 0
            else
                for ii = 1:nargin % Loops through the input arguments
                    if ischar(varargin{1})
                        evalin('caller',[varargin{ii} ';']); % this is an initial check to see if the variable exists
                        p(ii) = obj.addprop(varargin{ii}); % adds them as dynamic properties
                        obj.(varargin{ii}) = evalin('caller',[varargin{ii} ';']); % Fills in those properties with the values
                    else
                        p(ii) = obj.addprop(inputname(ii));
                        obj.(inputname(ii)) = varargin{ii};
                    end
                end
                obj.dynamicproperties = p; % here we assign the private dynamicproperties property, mainly for controlling these data
            end
        end
        
        %---------------- Manipulating Stored Data -------------------------------%
        function add(obj,varargin) % In order to add more data to our object
            try
                for ii = 1:nargin-1 % because there will always be "obj" there
                    % Overwrite the property
                    if ismember(inputname(ii+1),properties(obj))
                        obj.remove(inputname(ii+1));
                        obj.msgPrinter(sprintf('Overwriting: %s\n',inputname(ii+1)));
                    end
                    if ischar(varargin{ii})
                        dynprops(ii) = obj.addprop(varargin{ii}); % adds them as dynamic properties
                        obj.(varargin{ii}) = evalin('caller',[varargin{ii} ';']); % Fills in those properties with the values
                    else
                        dynprops(ii) = obj.addprop(inputname(ii+1));
                        obj.(inputname(ii+1)) = varargin{ii};
                    end
                    obj.dynamicproperties = [obj.dynamicproperties dynprops]; % extending the thing
                    
                end
            catch
                    obj.msgPrinter('Unknown error, data not added \n');       
            end
        end
        
        function remove(obj,varargin) % Getting rid of individual fields of data
            try
                dynamic_property_list = {obj.dynamicproperties.Name}; % Find the properties you want to get rid of
                isDeleteProperty = ismember(dynamic_property_list,varargin);
                delete(obj.dynamicproperties(isDeleteProperty)) % Get rid of thew
                obj.dynamicproperties = obj.dynamicproperties(~isDeleteProperty); % Update reference list
            catch
                obj.msgPrinter('Something went wrong, properties not deleted \n')
            end
        end
        
        function obj = reset(obj) % For clearing your entire data object, starting from scratch
            delete(obj.dynamicproperties);
        end

        function importStruct(obj,S)
            props = properties(obj);
            fields = fieldnames(S);
            for ii = 1:length(fields)      
                
                if ismember(fields{ii},props)
                    fieldname = strcat(fields{ii}, '_', inputname(2));
                    obj.msgPrinter(sprintf('Renamed field: %s -> %s\n',fields{ii},fieldname));
                else
                    fieldname = fields{ii};
                end   
                
                dynprops(ii) = obj.addprop(fieldname);
                obj.(fieldname) = S.(fields{ii});
                obj.dynamicproperties = [obj.dynamicproperties dynprops]; % extending the thing
            end
        end
        
        %----------------- Exporting Stored Data ---------------------------------%
        function varargout = export(obj,varargin) % Generally recommended, outputs to struct
            props = properties(obj);
            if nargin < 2 % create the structure based on queried input variables
                out = struct();
                for ii = 1:size(props,1)
                    out.(props{ii}) = obj.(props{ii});
                end
            else
                isExportProperty = ismember(props,varargin);
                for ii = 1:size(props,1)
                    if isExportProperty(ii)
                        out.(props{ii}) = obj.(props{ii});
                    end
                end
            end
            if nargout > 0 % If given an output argument, assign it. If not, output as the object name
                varargout{1} = out;
            else
                assignin('caller',sprintf('%s_export',inputname(1)),out);
            end
        end
        
        function exportVar(obj,varargin) % Generally not recommended, use exportData instead
            % obj.msgPrinter('Not recommended (uses assignin), better to access the properties directly...\n')
            props = properties(obj);
            
            if nargin < 2
                for ii = 1:size(props,1)
                    assignin('caller',props{ii},obj.(props{ii})); % not sure if base or caller better, we'll see...
                end
            else
                isExportProperty = ismember(props,varargin);
                for ii = 1:size(props,1)
                    if isExportProperty(ii)
                        assignin('caller',props{ii},obj.(props{ii})); % not sure if base or caller better, we'll see...
                    end
                end
                
            end
        end
        
        function out = get(obj,var)
            out = obj.(var);
        end
    end
    
    methods (Access = private)
        function msgPrinter(obj,str)
            fprintf(str);
        end
    end
end
