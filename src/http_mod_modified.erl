%% @author Ruslan Babayev <ruslan@babayev.com>
%% @copyright 2009, Ruslan Babayev
%% @doc This module handles requests that include `If-Modified-Since' and
%%      `If-Unmodified-Since' headers.
%%      Uses `file_info' flag.

-module(http_mod_modified).
-author('ruslan@babayev.com').

-export([init/0, handle/4]).

-include("http.hrl").

init() ->
    ok.

handle(_Socket, Request, undefined, Flags) ->
    FileInfo = proplists:get_value(file_info, Flags),
    #http_request{headers = Headers} = Request,
    case proplists:get_value('If-Modified-Since', Headers) of
	undefined ->
	    case proplists:get_value('If-Unmodified-Since', Headers) of
		undefined ->
		    {proceed, Request, undefined, Flags};
		Since ->
		    case http_lib:is_modified(FileInfo, Since) of
			true ->
			    http_lib:response(412);
			false ->
			    {proceed, Request, undefined, Flags}
		    end
	    end;
	Since ->
	    case http_lib:is_modified(FileInfo, Since) of
		true ->
		    {proceed, Request, undefined, Flags};
		false ->
		    http_lib:response(304)
	    end
    end;
handle(_Socket, Request, Response, Flags) ->
    {proceed, Request, Response, Flags}.
