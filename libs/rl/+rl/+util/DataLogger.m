classdef DataLogger < handle
    % DATALOGGER
    
    properties(Access = private)
        Buffer
        BufferSize
        CurrentIndex
        
        % validate function's params
        DataClassName (1, 1) string
        ValidateFuncHandles (1, :) cell
    end
    
    methods
        function this = DataLogger(bufferSize, dataClassName, validateFuncHandles)
            arguments
                bufferSize (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
                dataClassName (1, 1) string = ""
                validateFuncHandles (1, :) {mustBeFunctionHandleCell} = {}
            end
            this.BufferSize = bufferSize;
            this.DataClassName = dataClassName;
            this.ValidateFuncHandles = validateFuncHandles;
            
            reset(this);
        end
        
        function reset(this)
            this.CurrentIndex = 0;
            this.Buffer = cell(1, this.BufferSize);
        end
        
        function resize(this, newBufferSize)
            
            validateattributes(newBufferSize, {'double'}, {'scalar', 'nonnegative', 'integer'});
            
            if this.CurrentIndex > newBufferSize
                error("変更後のサイズよりも格納されているデータが多いためサイズを変更できません");
            end
            this.BufferSize = newBufferSize;
            oldData = getBuffer(this);
            reset(this);
            
            for i = 1 : length(oldData)
                this.append(oldData{i});
            end
        end
        
        function append(this, data)
            % validate append data
            if (this.DataClassName ~= "")
                if ~isa(data, this.DataClassName)
                    error('Invalid data class append. Expected class: %s Data class: %s', this.DataClassName, class(data));
                end
            end
            
            if (~isempty(this.ValidateFuncHandles))
                cellfun(@(x) x(data), this.ValidateFuncHandles)
            end
            if this.CurrentIndex == this.BufferSize
                error("Buffer is full");
            end
            
            this.CurrentIndex = this.CurrentIndex + 1;
            this.Buffer{this.CurrentIndex} = data; 
        end
        
        function [buffer, currentIdx] = getBuffer(this)
            buffer = this.Buffer;
            currentIdx = this.CurrentIndex;
        end
    end
end

% Validate function
function mustBeFunctionHandleCell(cell)
    if ~all(cellfun(@(x) isa(x, 'function_handle'), cell))
        error(message('MATLAB:integral:funArgNotHandle'));
    end
end