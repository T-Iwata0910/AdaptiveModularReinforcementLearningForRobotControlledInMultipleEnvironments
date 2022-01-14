function Agent = rlLQTAgent(varargin)
    % rlLQTAgent: Creates a LQT agent.
    %
    %   agent = rlLQTAgent(CRITIC) creates a LQT agent with default
    %   options and the specified critic representation.
    %
    %   agent = rlLQTAgent(CRITIC,OPTIONS) creates a LQT agent with
    %   the specified options. To create OPTIONS, use rlLQTAgentOptions.
    %
    %   agent = rlLQTAgent(CRITIC,OPTIONS, K0) creates a LQT agent with
    %   the specified options and initial weight. To create OPTIONS, use rlLQTAgentOptions.
    %
    % ver1.0.0 2020-02-11 T.Iwata Test create
    % ver1.1.0 2020-04-30 T.Iwata Add new option: initial representation weight
    % ver1.2.0 2020-05-02 T.Iwata ExperienceをAgentに保存できるように変更
    % ver1.2.1 2020-05-06 T.Iwata 旧バージョンでQ関数の初期化ができなくなってしまった現象を修正
    % ver1.3.0 2020-05-25 T.Iwata ノイズモデルを追加し，Optionで設定できるように変更
    % ver1.3.1 2020-05-31 T.Iwata ExperienceBufferをRL toolboxのものに変更
    % ver1.3.2 2021-01-01 T.Iwata sturate関数のバグによって複数行動を出力できなかった問題を修正
    
    % TODO
    
Agent = rl.agent.rlLQTAgent(varargin{:});

end