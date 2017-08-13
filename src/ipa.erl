
-module(ipa).

-define(ADD_WINS, add).
-define(REMOVE_WINS, remove).

-define(H_AW, [{dc, 1}, {tc, 2}, {d, 3}, {t, 4}, {i, 5}]).
-define(H_RW, [{tc, 1}, {t, 2}, {i, 3}, {dc, 4}, {d, 5}]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-export([new/0,
          touch/0, touch_cascade/0, insert/0, delete/0, delete_cascade/0,
          add_wins/0, remove_wins/0,
          is_visible/1, is_visible/2,
          status/2]).

new() ->
  insert().

touch() -> t.
touch_cascade() -> tc.
insert() -> i.
delete() -> d.
delete_cascade() -> dc.

add_wins() -> ?ADD_WINS.
remove_wins() -> ?REMOVE_WINS.

is_visible(ExState) ->
  is_visible(ExState, []).

is_visible(_, [dc | _ImplicitState]) -> false;
is_visible(ExplicitState, [tc | ImplicitState]) ->
  is_visible(ExplicitState, ImplicitState);
is_visible(i, []) -> true;
is_visible(t, []) -> true;
is_visible(d, []) -> false;
is_visible(_InvalidE, _InvalidI) -> 
  err.

status(Mode, [H | T]) ->
  Heu = heu(Mode),
  status(Heu, T, H).

status(Heu, [H | T], Current) ->
  Res = merge(Heu, H, Current),
  status(Heu, T, Res);
status(_Heu, [], Current) ->
  Current.

heu(?ADD_WINS) -> ?H_AW;
heu(?REMOVE_WINS) -> ?H_RW;
heu(_Invalid) -> err.

merge(Heu, X, Y) ->
  ScoreX = proplists:get_value(X, Heu),
  ScoreY = proplists:get_value(Y, Heu),
  if
    ScoreX >= ScoreY ->
      X;
    true ->
      Y
  end.

%%====================================================================
%% Eunit tests
%%====================================================================

-ifdef(TEST).
new_test() ->
  ?assertEqual(i, new()).

is_visible_ok_test() ->
  ?assertEqual(is_visible(i, [tc, tc]), true),
  ?assertEqual(is_visible(i, [dc, tc]), false),
  ?assertEqual(is_visible(t, [tc, tc]), true),
  ?assertEqual(is_visible(t, [dc, tc]), false),
  ?assertEqual(is_visible(d, [tc, tc]), false),
  ?assertEqual(is_visible(d, [dc, tc]), false).

is_visible_err_test() ->
  ?assertEqual(is_visible(random_value, random_value), err).

status_test() ->
  List1 = [d],
  List2 = [i, d, tc],
  List3 = [d, d, dc],
  List4 = [i, d, d],
  ?assertEqual(status(?ADD_WINS, List1), d),
  ?assertEqual(status(?ADD_WINS, List2), i),
  ?assertEqual(status(?ADD_WINS, List3), d),
  ?assertEqual(status(?ADD_WINS, List4), i).

-endif.
