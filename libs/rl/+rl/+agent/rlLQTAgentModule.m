classdef rlLQTAgentModule < rl.agent.rlLQTAgent & rl.agent.AbstractModuleAgent
    properties (Access=private)
        % JP: AMLQTでは，Q_evalにQ_{i-1}を使用する．
        % EN: In AMLQT, Q_{i-1} is used for Q_eval.
        PreviousPolicy
    end
    methods
        function this = rlLQTAgentModule(varargin)
            this = this@rl.agent.rlLQTAgent(varargin{:});
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Imprement abstract methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function val = evaluateModule(this, exp)
            % JP: 1ステップ状態遷移を元にモジュールの評価値を返す
            % EN: Return evaluate value based on 1 step state transition.
            
            x = exp{1}{:};
            u = exp{2}{:};
            r = exp{3};
            dx = exp{4}{:};
            gamma = this.AgentOptions.DiscountFactor;  % TODO: モジュール全体で統一する
            
            % 価値推定ができていないときの対策
            if isempty(this.PreviousPolicy)
                val = -Inf;  % TODO: 値を決定
                return
            end
            
            % JP: 式(9)の計算を行う．
            % EN: Eq. (9)
            targetQValue = r + gamma * getValue(this.Critic, dx, this.PreviousPolicy'*dx);
            TDError = targetQValue - getValue(this.Critic, x, u);
            if isa(TDError, 'dlarray')
                val = extractdata(TDError);
            else
                val = TDError;
            end
            
            val = -abs(val);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Over ride methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access=protected)
        function action = learn(this, exp)
            arguments
                this 
                exp (1, 5) cell
            end
            % JP: 方策が更新されたときにPreviousPolicyを更新する．
            % EN: When policy is updated, update PreviousPolicy.
            K = getPolicyParams(this);
            action = learnImpl(this, exp);
            dK = getPolicyParams(this);
            
            if K ~= dK
                this.PreviousPolicy = K;
            end
        end
    end
end
    