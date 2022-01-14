function Options = rlDiscreteLQTEnvOptions(varargin)
% rlDiscreteLQTEnvOptions: Create options for DiscreteLQT Environment.
%
%   OPT = rlDiscreteLQTEnvOptions returns the default options for rlLQTAgent. 
%
%   OPT = rlDiscreteLQTEnvOptions('Option1',Value1,'Option2',Value2,...) uses name/value
%   pairs to override the default values for 'Option1','Option2',...
%
%   Supported options are:
%
% %   tol                                 目標値との許容誤差
% %   TimesInARow                         連続何回許容誤差以内に入ったらエピソードを終了するか
% %
% %   See also: rlDiscreteLQTEnvt

% ver1.0.0 2020-06-14 T.Iwata Test create

Options = rl.option.rlDiscreteLQTEnvOptions(varargin{:});

end