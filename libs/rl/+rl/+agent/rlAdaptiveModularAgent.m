classdef rlAdaptiveModularAgent < rl.agent.AbstractAgent
    % rlAdaptiveModularAgent: Implements Adaptive Modular Reinforcement
    % Learning Agent

    % Copyright 2021 T.Iwata All right reserved
    
    %% Public Properties
    properties
        % Save
        SelectedModuleID (1, 1) rl.util.DataLogger
        EvaluateValues (1, 1) rl.util.DataLogger
        
        % JP: モジュールエージェント．cell配列でエージェントを保持する．
        % EN: Module Agents. Agents is lept in each cell array.
        ModuleAgents (:, 1) cell  % モジュールエージェント
    end

    properties (Access = protected)
        % JP: 警戒基準値．すべてのモジュール評価値がこの値以下かつ，
        %     後述の学習期間を経ている場合，新たなモジュールエージェントが生成される．
        %     論文中の\rhoに該当する
        % EN: Vigilance criterion. If evaluation value of all module is less than
        %     this value and all modules have passed the learning period, new
        %     module agent will be created.
        %     Corresponds to \rho in the jurnal.
        Vigilance (1, 1) {mustBeNonpositive}

        % JP: 学習期間．論文中の\lambdaに該当する
        % EN: Leaning period. Corresponds to \lambda in the jurnal.
        LearningPeriod (1, 1) {mustBeInteger, mustBeNonnegative}
        
        % JP: 各モジュールが行動決定に使用された回数を格納する．
        %     モジュールエージェントの要素数と一致しており，モジュールエージェントが新たに生成される度にリサイズされる
        %     論文中のNに該当する
        % EN: This variable stores the number of times each module was used to make an action decision.
        %     This variable size is match to module agent size.
        %     This variable is resized, when module agent is created. 
        %     Corresponds to N in the jurnal.
        SelectedModuleCount (:, 1) {mustBeInteger, mustBeNonnegative} = 0;

        % JP: 新しいモジュールエージェントを生成するための関数ハンドル
        %     論文中の createModule() に該当する
        % EN: Function hundle to create new module agent.
        %     Corresponding to createModule().
        CreateModuleFcnHdl (1, 1)
    end
    
    properties (Dependent)
        % Options to configure RL agent
        AgentOptions
    end
    
    properties (Access = private)
        % Private options to configure RL agent
        AgentOptions_ = [];
        
        SaveExperiences (1, 1) logical = false;
    end
    
    methods
        % Constructor
        function this = rlAdaptiveModularAgent(createModuleFcnHdl, agentOptions, options)
            arguments
                createModuleFcnHdl (1, 1) function_handle
                agentOptions (1, 1) rl.option.rlAdaptiveModularAgentOptions
                options.InitialModule (:, 1) cell = cell(0)
            end
            % Validate Inputs
            if nargin(createModuleFcnHdl) ~= 2
                error("Invalid createModuleFcnHdl: Input argument neq 2");
            end
            if nargout(createModuleFcnHdl) > 1  % 無名関数でインスタンスした場合はnargoutの戻り値は-1になるため
                error("Invalid createModuleFcnHdl: Output argument neq 1");
            end
            agent = feval(createModuleFcnHdl, [], []);
            if ~isa(agent, 'rl.agent.AbstractModuleAgent')
                error("Invalid createModuleFcnHdl: Created agent's class is not module agent");
            end
            
            % Validate InitialModule
            if ~all(cellfun(@(x) isa(x, class(agent)), options.InitialModule))
                error("Invalid Initial Module: Initial Module's class is unmatch createModuleFcn");
            end
            
            this.CreateModuleFcnHdl = createModuleFcnHdl;
            this.AgentOptions = agentOptions;
            this.ActionInfo = getActionInfo(agent);
            this.ObservationInfo = getObservationInfo(agent);
            
        end
        
        % get/set methods
        function set.AgentOptions(this, NewOptions)
            validateattributes(NewOptions,{'rl.option.rlAdaptiveModularAgentOptions'},{'scalar'},'','AgentOptions');
            
            this.AgentOptions_ = NewOptions;
            this.SampleTime = NewOptions.SampleTime;
            this.Vigilance = NewOptions.Vigilance;
            this.LearningPeriod = NewOptions.LearningPeriod;
            this.SaveExperiences = NewOptions.SaveExperiences;
        end
    end
    
    methods (Access = private)
        function createModule(this, moduleAgents, evaluateValues)
            % JP: 新しいモジュールを生成する関数
            % EN: This function is called to create new module agent.
            this.ModuleAgents{end+1} = this.CreateModuleFcnHdl(moduleAgents, evaluateValues);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Implement abstract methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function action = getActionWithExploration(this, observation)
            % TODO: Consider Implement
            action = getActionWithExploration(this.ModuleAgents{1}, observation);
        end
    end

    methods (Access=protected)
        function action = getActionImpl(this, observation)
            % TODO: Consider Implement
            action = getAction(this.ModuleAgents{1}, observation);
        end
        
        function action = learn(this, exp)
            % JP: AMRLエージェントが保持しているすべてのモジュールエージェントの
            %     評価値を算出 (ref. Algorithm 1 l. 14)
            % EN: Calculates the evaluation values of all module agents
            %     that the AMRL agent has. (ref. Algorithm 1 l. 14)
            evaluateValues = cellfun(@(x) evaluateModule(x, exp), this.ModuleAgents);
            
            % JP: 最大評価値のモジュールインデックスと評価値を取得する (ref. Algorithm 1 l. 15)
            % EN: Get maximum evaluate value and index in module agent. (ref. Algorithm 1 l. 15)
            [maxValue, idx] = max(evaluateValues);
            
            % JP: すべてのモジュール評価値が警戒基準以下かつ，
            %     学習期間を経ている場合，新たなモジュールエージェントを生成する． (ref. Algorithm 1 l. 16-26)
            % EN: If evaluation value of all module is less than
            %     vigilance criterion and all modules have passed the learning
            %     period, new module agent will be created. (ref. algorithm 1 l.16-26)
            if maxValue < this.Vigilance
                if min(this.SelectedModuleCount) > this.LearningPeriod 
                    idx = length(this.ModuleAgents) + 1;
                    createModule(this, this.ModuleAgents, evaluateValues);
                    this.SelectedModuleCount(idx) = 0;
                else
                    [~, idx] = min(this.SelectedModuleCount);
                end
            end
            
            % JP: 学習・行動決定を行うモジュールエージェントの選択回数をインクリメントする(ref. Algorithm 1 l. 27)
            % EN: Increment the number of selections of module agents that make learning / action decisions(ref. Algorithm 1 l. 27)
            this.SelectedModuleCount(idx) = this.SelectedModuleCount(idx) + 1;
            
            % JP: 現在の経験exp = {state,action,reward,nextstate,isdone}を使用して
            %     最も評価値の高かったモジュールエージェントの学習を行う．
            %     それに加えて，最も評価値の高かったモジュールエージェントを
            %     使用して行動を決定する． (ref. Algorithm 1 l.28-29)
            % EN: Learn module agent which has highest evaluate value using
            %     current experiences where exp =
            %     {state,action,reward,nextstate,isdone}.
            %     In addition, Decide action using module agent which has
            %     highest evaluate value.
            action = learn(this.ModuleAgents{idx}, exp);
            
            
            % Logging
            append(this.SelectedModuleID, idx);
            append(this.EvaluateValues, evaluateValues);
        end
        
        function trainOptions = validateAgentTrainingCompatibilityImpl(this, trainOptions)
        end

        function p = getLearnableParametersImpl(this)
        end

        function setLearnableParametersImpl(this, p)
        end
        
        function HasState = hasStateImpl(this)
        end

        function resetImpl(this)
            % JP: 実験データをロギングするための設定
            %   AbstractPolicyのstepメソッドでexpを保存する.
            % EN: To log experiment results
            if this.SaveExperiences
                attachLogger(this, this.MaxSteps);
                this.SelectedModuleID = rl.util.DataLogger(this.MaxSteps, "double", {@mustBePositive});
                this.EvaluateValues = rl.util.DataLogger(this.MaxSteps, "double");
            end
            
            % JP: AMRLのリセット処理
            % EN: Reset process for AMRL
            if isempty(this.ModuleAgents)
                this.createModule([], []);
            end
            for i = 1 : length(this.ModuleAgents)
                this.ModuleAgents{i}.MaxSteps = this.MaxSteps;
                this.ModuleAgents{i}.reset();
            end
        end
    end
end