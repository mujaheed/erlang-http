%% @author Ruslan Babayev <ruslan@babayev.com>
%% @copyright 2009, Ruslan Babayev
%% @doc This module implements access control based on file access mode.
%%      Uses `path' and sets `file_info' flags.

-module(http_mod_access).
-author('ruslan@babayev.com').

-export([init/0, handle/4]).

-include("http.hrl").
-include_lib("kernel/include/file.hrl").

init() ->
    ok.

handle(_Socket, Request, undefined, Flags) ->
    Path = proplists:get_value(path, Flags),
    case file:read_file_info(Path) of
	{ok, #file_info{access = A} = FI} when A == read; A == read_write ->
	    {proceed, Request, undefined, [{file_info, FI} | Flags]};
	{ok, _FileInfo} ->
	    http_lib:response(403);
	{error, _Reason} ->
	    http_lib:response(404)
    end;
handle(_Socket, Request, Response, Flags) ->
    {proceed, Request, Response, Flags}.
