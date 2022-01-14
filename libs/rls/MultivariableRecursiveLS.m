classdef MultivariableRecursiveLS < handle
    % 
    % Algorithm: ADAPTIVE FILTERING PREDICTION AND CONTROL, pp. 96--97, 1987
            
    properties
        ForgettingFactor (1, 1) double {mustBePositive} = 1
        
    end
    properties(Access=protected)
        Covariance
        Parameter
    end
    properties (Access=protected)
        InputSize (1, 1) double {mustBePositive} = 1
        OutputSize (1, 1) double {mustBePositive} = 1
    end
    
    methods
        function obj = MultivariableRecursiveLS(inputSize, outputSize, options)
            arguments
                inputSize (1, 1) double {mustBePositive}
                outputSize (1, 1) double {mustBePositive}
                options.initialParameter double = double.empty
                options.initialCovariance double = double.empty
                options.ForgettingFactor (1, 1) double {mustBeNonnegative, mustBeLessThanOrEqual(options.ForgettingFactor,1)} = 1
            end
            
            if isempty(options.initialParameter)
                options.initialParameter = -0.05 + 0.1 * rand(inputSize, outputSize);
            end
            if isempty(options.initialCovariance)
                options.initialCovariance = eye(inputSize) * 1e4;
            end
            
            validateattributes(options.initialParameter, {'double'}, {'size', [inputSize, outputSize]}, 'initialParameter');
            validateattributes(options.initialCovariance, {'double'}, {'size', [inputSize, inputSize]}, 'initialCovariance');
            
            obj.Parameter = options.initialParameter;
            obj.Covariance = options.initialCovariance;
            obj.ForgettingFactor = options.ForgettingFactor;
            
            obj.InputSize = inputSize;
            obj.OutputSize = outputSize;
        end
    end
    methods
        function [thetaHat, yHat] = step(obj, y, u)
            % 
            % Inputs
            %   y [m 1] output vector at time i, y[i].
            %   u [p 1] input vector at time i, u[i].
            %
            % Outputs
            %  thetaHat [p m] parameter vetcor at time i, theta[i].
            %  yHat [m 1] predict from u[i] and theta[i-1].
            
            % Validation
            validateattributes(y, {'double'}, {'size', [obj.OutputSize, 1]}, 'y');
            validateattributes(u, {'double'}, {'size', [obj.InputSize, 1]}, 'u');
            
            % Calucrate estimate error
            % e[i] = y[i] - u'[i]theta[i-1]
            yHat =  obj.predict(u);
            err = y - yHat;
            
            % Update Parameter
            % 
            updateParameters(obj, err, u);
            thetaHat = obj.Parameter;        
        end
        
        function yHat = predict(obj, u)
            % Validate arguments
            validateattributes(u, {'double'}, {'size', [obj.InputSize, 1]}, 'u');
            
            yHat = obj.Parameter' * u;
        end
        
        function updateParameters(obj, err, u)
            % Validate arguments
            validateattributes(err, {'double'}, {'size', [obj.OutputSize, 1]}, 'err');
            validateattributes(u, {'double'}, {'size', [obj.InputSize, 1]}, 'u');
            
            P = obj.Covariance;
            theta = obj.Parameter;
            lambda = obj.ForgettingFactor;
            
            obj.Parameter = theta + (P * u) / (lambda + u'*P*u) * err';
            obj.Covariance = 1/lambda * (P - (P*u*u'*P)/(lambda + u'*P*u));            
        end
    end
    
    % get/set metods
    methods
        function setForgettingFactor(obj, value)
            arguments
                obj
                value (1, 1) double {mustBePositive}
            end
            obj.ForgettingFactor = value;
        end
        
        function theta = getParameter(obj)
            theta = obj.Parameter;
        end
    end
    
end