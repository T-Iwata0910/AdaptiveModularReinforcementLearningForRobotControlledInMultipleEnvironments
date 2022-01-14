classdef rlLQTAgent < rl.agent.CustomAgent
    % rlLQTAgent: Implements Linear Quadratic Reinforcement Learning Agent
    %
    
    % ver1.0.0 2020-02-11 T.Iwata Test create
    % ver1.1.0 2020-04-30 T.Iwata Add new option: initial representation weight
    % ver1.2.0 2020-05-02 T.Iwata ExperienceをAgentに保存できるように変更
    % ver1.2.1 2020-05-06 T.Iwata 旧バージョンでQ関数の初期化ができなくなってしまった現象を修正
    % ver1.3.0 2020-05-25 T.Iwata ノイズモデルを追加し，Optionで設定できるように変更
    % ver1.3.1 2020-05-31 T.Iwata ExperienceBufferをRL toolboxのものに変更
    
    % copyright T.Iwata 2021 All right reserved
    
    %% Public Properties
    properties
        % JP: ログ用のメンバ変数の設定
        % EN: variable for logging
        
        % TD error buffer
        TDErrorBuffer (1, 1) rl.util.DataLogger
        
        % Buffer for policy
        PolicyParamsBuffer (1, 1) rl.util.DataLogger
    end

    properties (Access = protected)

        % Actor
        Actor (1, 1)

        % Critic
        Critic (1, 1)
        
        % NoiseModel
        NoiseModel

        % JP: 学習に使用する経験を保存するためのバッファ
        % EN: Buffer to keep experience used for learning
        ExperienceBuffer
    end 
    
    properties (Access = private)
        % Private options to configure RL agent
        AgentOptions_ = [];
        
        % JP: 1イテレーションあたりのステップ数（この数で一度方策の更新を行う）
        % EN: Number of steps per iteration (Update the policy once every time this number elapses.)
        StepNumPerIteration        
        
        % JP: ゲインの更新幅がこの値以下になったら学習を終了する
        % EN: Training ends when the gain update width is less than or equal to this value.
        StopExplorationValue (1, 1) double {mustBeNonnegative};
        StopExplorationFlg (1, 1) logical = false;
        
        % JP: ログを保存するかを指定するフラグ
        % EN: Flag that specifies whether to save the log
        SaveExperiences (1, 1) logical
    end

    properties (Dependent)
        % Options to configure RL agent
        AgentOptions
    end
    
    methods (Access = protected)
        function actor = createActor(this, initialParameter)
            % JP: 方策は，状態とフィードバックゲインの線形結合のため，特徴関数は恒等関数を使用する．
            % EN: Policy is linear combination of states and feedback gain,
            %     therefore identity function is set for the feature function.
            model{1} = @(x) x;
            model{2} = initialParameter;
            actor = rlDeterministicActorRepresentation(model, this.ObservationInfo, this.ActionInfo); 
        end

        % Create critic 
        function critic = createCritic(obj)
            % JP: Criticを生成するためのメソッド
            %     Criticパラメータの初期値は0.1を使用する．
            % EN: Method to create critic.
            %     Parameters of critic is initialized to 0.1.
            observeDim = obj.ObservationInfo.Dimension(1);
            actionDim = obj.ActionInfo.Dimension(1);
            n = observeDim+actionDim;
            w0 = 0.1*ones(0.5*(n+1)*n,1);
            
            if verLessThan('rl', '1.2')
                critic = rlRepresentation(@(x,u) computeQuadraticBasis(x,u,n),w0,...
                    {obj.ObservationInfo,obj.ActionInfo});
            else
                critic = rlQValueRepresentation({@(x,u) computeQuadraticBasis(x,u,n),w0},...
                    obj.ObservationInfo,obj.ActionInfo);
            end
        end
    end
    
    %% MAIN METHODS
    methods
        % Constructor
        function this = rlLQTAgent(varargin)
            % input parser
            narginchk(2, 4);  % 引数の数を確認（最小:2, 最大:4）
            % Call the abstract class constructor
            this = this@rl.agent.CustomAgent();
            
            % valate inputs
            % see also: rl.util.parseAgentInputs.m
            % infomation check
            oaInfo = varargin(cellfun(@(x) isa(x, 'rl.util.RLDataSpec'), varargin));
            if numel(oaInfo) ~= 2
                error('Action or obsevation infomation is invalid');
            end
            
            % options check
            UseDefault = false;
            opt = varargin(cellfun(@(x) isa(x, 'rl.option.AgentGeneric'), varargin));
            
            % initial weight check
            k0 = varargin(cellfun(@(x) isa(x, 'numeric'), varargin));
            
            % whole check
            if numel(varargin)~=( numel(oaInfo)+numel(opt)+numel(k0) )
                error(message('rl:agent:errInvalidAgentInput'));
            end
            
            if isempty(opt)
                opt{1} = rlLQTAgentOptions;
                UseDefault = true;
            else
                % check otption is compatible
                if ~isa(opt{1}, 'rl.option.rlLQTAgentOptions')
                    error(message('rl:agent:errMismatchedOption'));
                end
            end
            
            if isempty(k0)
                k0 = rand(oaInfo{2}.Dimension(1), oaInfo{1}.Dimension(1));
            else
                k0 = k0{1};
                validateattributes(k0, {'numeric'}, {'ncols', oaInfo{1}.Dimension(1)}, '', 'k0');
            end
            
            % set ActionInfo and ObservationInfo
            this.ObservationInfo = oaInfo{1};
            this.ActionInfo = oaInfo{2};
            
            % set agent option(ノイズモデルのインスタンスでthis.ActionInfoを使用するのでActionInfoの設定を終えてから)
            this.AgentOptions = opt{1};
            
            % Create the critic representation
            this.Critic = createCritic(this);

            % Initialize the gain matrix
            this.Actor = createActor(this, -k0'); 
        end

        function policy = getPolicyParams(this)
            policy = getLearnableParameters(this.Actor);
            if iscell(policy)
                policy = policy{1};
            end
            if isdlarray(policy)
                policy = extractdata(policy);
            end
        end
    end

    %% get/set methods
    methods
        function set.AgentOptions(this, NewOptions)
            validateattributes(NewOptions,{'rl.option.rlLQTAgentOptions'},{'scalar'},'','AgentOptions');
            
            % check if the experience buffer needs to be rebuild
            rebuildExperienceBuffer = isempty(this.ExperienceBuffer) || ...
                this.AgentOptions_.StepNumPerIteration ~= NewOptions.StepNumPerIteration;
            % check to see if we need to rebuild the noise model
            rebuildNoise = isempty(this.NoiseModel) || ...
                ~isequal(this.AgentOptions_.NoiseOptions,NewOptions.NoiseOptions);
            
            this.AgentOptions_ = NewOptions;
            this.SampleTime = NewOptions.SampleTime;
            this.StepNumPerIteration = NewOptions.StepNumPerIteration;
            this.StopExplorationValue = NewOptions.StopExplorationValue;
            this.SaveExperiences = NewOptions.SaveExperiences;
            
            % build the experience buffer if necessary
            if rebuildExperienceBuffer
                if isempty(this.ExperienceBuffer)
                    buildBuffer(this);
                else
                    resize(this.ExperienceBuffer,this.AgentOptions_.StepNumPerIteration);
                end
            end
            
            % build the noise model if necessary
            if rebuildNoise
                % extract the noise options
                noiseOpts = this.AgentOptions_.NoiseOptions;

                % create the noise model
                actionDims = {this.ActionInfo.Dimension}';
                this.NoiseModel = rl.util.createNoiseModelFactory(...
                    actionDims,noiseOpts,getSampleTime(this));
            end
        end

        function Options = get.AgentOptions(this)
            Options = this.AgentOptions_;
        end
    end
    
    %% Implementation of abstract parent protected methods
    methods (Access = protected)
        function action = getActionWithExplorationImpl(obj,Observation)
            % Given the current observation, select an action
            action = getAction(obj,Observation);
            
            % Add random noise to action
            action = applyNoise(obj.NoiseModel, action);

            % saturate the actions
            action = saturate(obj.ActionInfo, action);
            
            % If the version of MATLAB is earlier than 2020a 
            % and training is performed in the simulink environment,
            % Action must be an array, not a cell.
            if verLessThan("rl", "2.0")
                if iscell(action)
                    action = action{1};
                end
            end
        end
        
        % learn from current experiences, return action with exploration
        % exp = {state,action,reward,nextstate,isdone}
        function action = learnImpl(obj,exp)
            % JP: 探索終了フラグが成立していないときに方策反復による方策の更新を行う
            % EN: If the search end flag is not satisfied, the policy is updated by Policy Iteration.
            if ~obj.StopExplorationFlg
                % JP: 経験をExperience bufferに格納する
                % Store experiences to experience buffer.
                appendExperience(obj, exp);
                
                if obj.ExperienceBuffer.Length >= obj.StepNumPerIteration
                    % JP: 価値評価を実施し，価値関数Q^{pi_{i-1}} -> Q^{pi_i}と更新する
                    % EN: Execute value evaluation, that update
                    % Q^{pi_{i-1}} -> Q^{pi_i}.
                    valueEvaluation(obj);
                    
                    % JP: ExperienceBufferに格納されている経験を使用して方策を更新
                    % EN: Update policy using the experience stored in the
                    %     experience buffer.
                    policyImprovement(obj);

                    % Reset the experience buffers
                    reset(obj.ExperienceBuffer);
                    
                    % JP: 方策パラメータの更新幅が一定以下になったら探索終了フラグを成立させる．
                    % EN: When the update width of the policy parameter becomes less than a certain level, 
                    %     the search end flag is established.
                    [KBuffer, idx] = getBuffer(obj.PolicyParamsBuffer);
                    kDiff = (-getPolicyParams(obj)' - KBuffer{idx});
                    if isdlarray(kDiff)
                        kDiff = extractdata(kDiff);
                    end
                    kNorm = norm(kDiff);
                    if (kNorm < obj.StopExplorationValue)
                        obj.StopExplorationFlg = true;
                    end
                    
                    % JP: 更新された方策パラメータをロギング
                    % EN: Log updated policy parameter.
                    append(obj.PolicyParamsBuffer, -getPolicyParams(obj)');
                end

                % Find and return an action with exploration
                action = getActionWithExploration(obj,exp{4});
            else
                action = getAction(obj,exp{4});
            end
            
            % JP: MATLABのバージョンが2020a以前の場合，simulink環境では，行動を配列で指定する必要がある．
            % EN: If the version of MATLAB is earlier than 2020a 
            %     and training is performed in the simulink environment,
            %     Action must be an array, not a cell.
            if verLessThan("rl", "2.0")
                if iscell(action)
                    action = action{1};
                end
            end
        end
          
        % Action methods
        function action = getActionImpl(obj,Observation)
            % Given the current state of the system, return an action.
            action = getAction(obj.Actor, Observation);
        end
        
        function resetImpl(this)
            % JP: 学習開始時に1度だけ実行
            % EN: Execute once, when train is starting
            
            % JP: ログ変数の初期化
            % EN: Initialize for logging
            % ※RL toolboxのtrainで学習した時には使用することができない(途中で捨てられる)(?)
            if this.SaveExperiences
                attachLogger(this, this.MaxSteps);
                this.TDErrorBuffer = rl.util.DataLogger(floor(this.MaxSteps/this.StepNumPerIteration) + 1, "double");
                this.PolicyParamsBuffer = rl.util.DataLogger(this.MaxSteps, "double");

                % Store InitialPolicy
                append(this.PolicyParamsBuffer, -getPolicyParams(this)');
            end
            
            % reset the noise model
            reset(this.NoiseModel);
            
            this.StopExplorationFlg = false;
        end
    end
    
    methods(Hidden)
        function appendExperience(this,experiences)
            % append experiences to buffer
            append(this.ExperienceBuffer,{experiences});
        end
        
        function valueEvaluation(obj)
            % Wait N steps before updating critic parameters
            gamma = obj.AgentOptions.DiscountFactor;
            oaDim = obj.ObservationInfo.Dimension(1) + obj.ActionInfo.Dimension(1);
            yBuf = zeros(obj.ExperienceBuffer.Length, 1);
            hBuf = zeros(obj.ExperienceBuffer.Length, 0.5*oaDim*(oaDim+1));
            TDError = zeros(obj.ExperienceBuffer.Length, 1);
            minibatch = getLastNData(obj.ExperienceBuffer, obj.StepNumPerIteration);

            for i = 1 : obj.ExperienceBuffer.Length
                % Parse the experience input
                x = minibatch{i}{1}{1};
                u = minibatch{i}{2}{1};
                r = minibatch{i}{3};
                dx = minibatch{i}{4}{1};
                
                da = getAction(obj.Actor, {dx});
                if iscell(da)
                    da = da{:};
                end

                % In the linear case, critic evaluated at (x,u) is Q1 = theta'*h1,
                % critic evaluated at (dx,-K*dx) is Q2 = theta'*h2. The target
                % is to obtain theta such that Q1 - gamma*Q2 = y, that is,
                % theta'*H = y. Following is the least square solution.
                h1 = computeQuadraticBasis(x,u,oaDim);
                h2 = computeQuadraticBasis(dx, da, oaDim);
                H = h1 - gamma* h2;

                yBuf(i, 1) = r;
                hBuf(i, :) = H;

                % JP: TD誤差を計算
                % EN: Caluculate TD Error.
                if verLessThan('rl', '1.2')
                    TDError(i) = r + gamma * ...
                        evaluate(obj.Critic, {dx, da}) - ...
                            evaluate(obj.Critic, {x, u});
                else
                    buf = r + gamma * getValue(obj.Critic, {dx}, {da}) - getValue(obj.Critic, {x}, {u});
                    TDError(i) = buf.extractdata;
                end
            end

            % Update the critic parameters based on the batch of
            % experiences
            theta = pinv(hBuf) * yBuf;
            obj.Critic = setLearnableParameterValues(obj.Critic,{theta});

            % Store TD error to buffer
            append(obj.TDErrorBuffer, mean(abs(TDError)));
        end

        function policyImprovement(obj)
            w = getLearnableParameterValues(obj.Critic);
            w = w{1};
            observeDim = obj.ObservationInfo.Dimension(1);
            actionDim = obj.ActionInfo.Dimension(1);
            n = observeDim+actionDim;
            idx = 1;
            for r = 1:n
                for c = r:n
                    Phat(r,c) = w(idx);
                    idx = idx + 1;
                end
            end
            H  = 1/2*(Phat+Phat');
            Huu = H(observeDim+1:end,observeDim+1:end);
            Hux = H(observeDim+1:end,1:observeDim);
            if rank(Huu) == actionDim
                k = Huu\Hux;
            else
                k = -getPolicyParams(obj)';
            end

            % Derive a new gain matrix based on the new critic parameters
            obj.Actor = setLearnableParameters(obj.Actor, {-k'});
        end
    end
    
    methods(Access= private)
        function buildBuffer(this)
            this.ExperienceBuffer = rl.util.ExperienceBuffer(...
                this.AgentOptions_.StepNumPerIteration, ...
                this.ObservationInfo, ...
                this.ActionInfo);
        end
    end
end

%% local function
function B = computeQuadraticBasis(x,u,n)
z = cat(1,x,u);
idx = 1;
for r = 1:n
    for c = r:n
        if idx == 1
            B = z(r)*z(c);
        else
            B = cat(1,B,z(r)*z(c));
        end
        idx = idx + 1;
    end
end
end
