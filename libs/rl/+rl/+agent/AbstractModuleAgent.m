classdef (Abstract) AbstractModuleAgent < handle
% ABSTMODULEAGENT
% 
% JP: AMRLエージェントを構成するモジュールの基本クラス．
%     実装するために次のメソッドを必要とします．
%
%     val = evaluateModule(this, exp)
%
% EN: Base class for module that constitute AMRL agent.
%     Requires the following methods to be implemented:
%
%     val = evaluateModule(this, exp)

% Copyright 2021 T.Iwata Allright reserved

    methods(Abstract)
        % en: Return evaluate value of module based on 1 step state transition
        % jp: 1ステップ状態遷移を元にモジュールの評価値を返す
        val = evaluateModule(this, exp);
    end
end