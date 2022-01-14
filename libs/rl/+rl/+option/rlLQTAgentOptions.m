classdef rlLQTAgentOptions < rl.option.AgentGeneric
% rlLQTAgentOptions: Create options for LQT control Agent.
%
%   OPT = rlLQTAgentOptions returns the default options for rlLQTAgent. 
%
%   OPT = rlLQTAgentOptions('Option1',Value1,'Option2',Value2,...) uses name/value
%   pairs to override the default values for 'Option1','Option2',...
%
%   Supported options are:
%
% %   DiscountFactor                      Discount factor to apply to future rewards during training
% %   StepNumPreIteration                 1イテレーションあたりのステップ数
% %   StopExplorationValue                学習を終了させる値
% %   SaveExperiences                     ExperienceをAgentに保存するオプション
% %   NoiseOptions                        Parameters for Ornstein Uhlenbeck noise
% %       InitialAction                       Initial state of the noise model
% %       Mean                                Mean of the noise model
% %       MeanAttractionConstant              Constant used to attract the process toward the mean
% %       Variance                            Variance of the random process
% %       VarianceDecayRate                   Rate of noise variance decay with each step of the noise model 
% %
% %   See also: rlLQTAgent

% ver1.0.0 2020-02-11 T.Iwata Test create
% ver1.1.0 2020-04-30 割引率を追加
% ver1.1.0 2020-05-02 ExperienceをAgentに保存するオプションを追加
% ver1.2.0 2020-05-25 ノイズのモデルを選択できるように変更
% ver1.3.0 2020-12-31 探索ノイズの終了条件を追加
    
    
    properties
        % Number for estimator update
        StepNumPerIteration
        StopExplorationValue
        SaveExperiences
        NoiseOptions
    end
    
    methods
        function obj = rlLQTAgentOptions(varargin)
            obj = obj@rl.option.AgentGeneric(varargin{:});
            
            parser = obj.Parser;
            addParameter(parser, 'StepNumPerIteration', 10);
            addParameter(parser, 'StopExplorationValue', 0);
            addParameter(parser, 'SaveExperiences', false);
            addParameter(parser, 'NoiseOptions', rl.option.UniformActionNoise);
            
            
            parse(parser, varargin{:});
            obj.Parser = parser;
            obj.StepNumPerIteration = parser.Results.StepNumPerIteration;
            obj.StopExplorationValue = parser.Results.StopExplorationValue;
            obj.SaveExperiences = parser.Results.SaveExperiences;
            obj.DiscountFactor =  parser.Results.DiscountFactor;
            obj.NoiseOptions = parser.Results.NoiseOptions;
        end

        % Varidate functions
        function obj = set.StepNumPerIteration(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'real', 'integer', 'positive', 'finite'}, '', 'StepNumPerIteration');
            obj.StepNumPerIteration = value;
        end
        
        function obj = set.StopExplorationValue(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'real', 'nonnegative', 'finite'}, '', 'StopExplorationValue');
            obj.StopExplorationValue = value;
        end
        
        function obj = set.SaveExperiences(obj, value)
            validateattributes(value, {'logical'}, {'scalar'}, '', 'SaveExperiences');
            obj.SaveExperiences = value;
        end
        
        function obj = set.NoiseOptions(obj,Value)
            validateattributes(Value,{'rl.option.OrnsteinUhlenbeckActionNoise','rl.option.GaussianActionNoise','rl.option.UniformActionNoise'},{'scalar'},'','NoiseOptions');
            obj.NoiseOptions = Value;
        end    
        
    end
end
