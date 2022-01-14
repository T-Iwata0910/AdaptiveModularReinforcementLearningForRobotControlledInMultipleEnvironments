classdef rlMultipleEnvironment < rl.env.MATLABEnvironment
% RLMULTIPLEENVIRONMENT: 

    properties
        SubEnvironments (1, :) cell
    end
    properties(Access=protected)
        StepNum (1, 1) double {mustBeNonnegative}
        State
        % JP: 各時間ステップで採用するサブ環境のインデックスを格納
        % EN: Stores indexes of the sub-environment adopted in each time step
        ContextSequence (:, 1) double {mustBePositive, mustBeInteger}
        % JP: 初期状態を観測するときに使用するサブ環境のインデックスを格納
        % EN: Stores the index of the sub-environment adopted in first time.
        InitialStateDistributionContext (1, 1) double {mustBePositive, mustBeInteger} = 1
    end
    
    methods
        function this = rlMultipleEnvironment(subEnvs, contextSequence, options)
            arguments
                subEnvs (1, :) cell
                contextSequence (:, 1) double {mustBePositive, mustBeInteger}
                options.InitialStateDistributionContext (1, 1) double {mustBePositive, mustBeInteger} = 1;
            end
            
            % Validate subEnvs
            % JP: subEnvsがすべて同じクラスであることを検証
            % EN: Verify that all subEnvs are in the same class.
            envNum = length(subEnvs);
            for i = 1 : envNum
                if ~isa(subEnvs{i}, class(subEnvs{1}))
                    error("subEnvs error! different env in context")
                end
            end
            
            % Validate contextSequence
            if (max(contextSequence) > envNum)
                error("Context Squence is out of range!!");
            end
            
            % Validate Initial Distribution Context
            if (max(options.InitialStateDistributionContext) > envNum)
                error("Initial Distribution Context is out of range!!");
            end
            
            ObservationInfo = getObservationInfo(subEnvs{1});
            ActionInfo = getActionInfo(subEnvs{1});
            
            this = this@rl.env.MATLABEnvironment(ObservationInfo, ActionInfo);
            
            this.SubEnvironments = subEnvs;
            this.ContextSequence = contextSequence;
            this.InitialStateDistributionContext = options.InitialStateDistributionContext;
        end
        
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            activeEnv = this.SubEnvironments{this.ContextSequence(this.StepNum+1)};
            
            activeEnv.State = this.State;
            [Observation,Reward,IsDone,LoggedSignals] = step(activeEnv, Action);
            
            this.StepNum = this.StepNum + 1;
            this.State = Observation;
            
            % (optional) use notifyEnvUpdated to signal that the
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
        
        function initialObservation = reset(this)
            for i = 1 : length(this.SubEnvironments)
                if (i == this.InitialStateDistributionContext)
                    initialObservation = this.SubEnvironments{i}.reset();
                else
                    this.SubEnvironments{i}.reset();
                end
            end
            this.StepNum = 0;
            this.State = initialObservation;
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
    end
end