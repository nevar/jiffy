%% @author Slava Yurin <YurinVV@ya.ru>
-module(jiffy_SUITE).

-include_lib("common_test/include/ct.hrl").

%% ct.
-export([all/0]).
-export([groups/0]).
-export([end_per_suite/1]).
-export([init_per_suite/1]).

%% Tests
-export([eunit/1]).
-export([jiffy_01_yajl_tests/1]).
-export([jiffy_10_short_double_tests/1]).

%- Test suite -----------------------------------------------------------------%
all() ->
	[{group, all}].

groups() ->
	Test = [eunit, jiffy_01_yajl_tests, jiffy_10_short_double_tests],
	[{all, [parallel], Test}].

%- Setup/clean function -------------------------------------------------------%
init_per_suite(Config) ->
	ok = application:start(jiffy),
	Config.

end_per_suite(_Config) ->
	ok = application:stop(jiffy),
	ok.

%- Tests ----------------------------------------------------------------------%
eunit(_Config) ->
	EunitTest =
		[ jiffy_02_literal_tests
		, jiffy_03_number_tests
		, jiffy_04_string_tests
		, jiffy_05_array_tests
		, jiffy_06_object_tests
		, jiffy_07_compound_tests
		, jiffy_08_halfword_tests
		, jiffy_09_reg_issue_24_tests
		, jiffy_11_proper_tests
		, jiffy_12_error_tests
		, jiffy_13_whitespace_tests
		, jiffy_14_bignum_memory_leak
		],
	ok = eunit:test(EunitTest, [verbose]).

jiffy_01_yajl_tests(Config) ->
	DataDir = ?config(data_dir, Config),
    CasesPath = filename:join([DataDir, "cases", "*.json"]),
    FileNames = lists:sort(filelib:wildcard(CasesPath)),
    Cases = lists:map(fun(F) -> make_pair(F) end, FileNames),
    [test(Case) || Case <- Cases],
	ok.

jiffy_10_short_double_tests(Config) ->
	File = filename:join(?config(data_dir, Config), "short-doubles.txt"),
    {ok, Fd} = file:open(File, [read, binary, raw]),
	0 = check_loop(Fd, 0),
	ok.

%- Helper function ------------------------------------------------------------%
check_loop(Fd, Acc) ->
    case file:read_line(Fd) of
        {ok, Data} ->
            V1 = re:replace(iolist_to_binary(Data), <<"\.\n">>, <<"">>),
            V2 = iolist_to_binary(V1),
            V3 = <<34, V2/binary, 34>>,
            R = jiffy:encode(jiffy:decode(V3)),
            case R == V3 of
                true -> check_loop(Fd, Acc);
                false -> check_loop(Fd, Acc + 1)
            end;
        eof ->
            Acc
    end.

make_pair(FileName) ->
    {ok, Json} = file:read_file(FileName),
    BaseName = filename:rootname(FileName),
    ErlFname = BaseName ++ ".eterm",
    {ok, [Term]} = file:consult(ErlFname),
    {filename:basename(BaseName), Json, Term}.

test({Name, Json, {error, _} = Erl}) ->
	ct:log(Name),
	Erl = (catch jiffy:decode(Json));
test({Name, Json, Erl}) ->
	ct:log(Name),
	Erl = jiffy:decode(Json).
