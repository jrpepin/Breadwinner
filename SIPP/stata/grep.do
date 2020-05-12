//======
//====== This do file searches all do files in the current directory
//====== for any of the arguments specified on the command line.
//======
//====== Example use:  do grep use save append using
//======     to find all/most of the places a dataset name is specified.
//======
//====== It searches only the first 200 characters of each line.
//======
//====== It is not sophisticated.  I don't know how it behaves if you
//====== try to enter a multiple word search term with quotes around it,
//====== for example.  But it works for single-word search terms composed
//====== of normal characters.
//======
//====== And the output is ugly.  But it beats not being able to search.
//====== Suggestions for improvement (or just making the improvements) welcome.
//======


//= Save dataset state so we can restore it before we leave.
preserve

//= This gets the list of do files in the current directory into a local macro.
local files : dir "`c(pwd)'" files "*.do"


//= This loop builds the search expression, taking each argument as a search term.
//= If any of the search terms is found, the input line is considered to match.
//= The end result is (strpos(s, "term1") > 0) | (strpos(s, "term2") > 0) | ...".
//=
//= If you want to search only for lines that contain ALL the search terms,
//= you can change the '|' ot an '&'.
//= This is an opportunity to make this do file more general -- we could take an
//= optional argument that flips the sense from OR to AND.
//=
//= Other possible improvements: 
//=    implement the grep -i flag, ignoring case in the search terms;
//=    implement the grep -2 flag, matching search terms only as stand-alone words,
//=    not as substrings of a longer word.
local full_search `"(strpos(s, "`1'") > 0)"'
local i = 2
while ("``i''" != "") {
	local full_search `"`full_search' | (strpos(s, "``i''") > 0)"'
	local ++i
}


//= This loops through each file.
//= It treats each file as a dataset, and reads the first 200 characters of each line
//= into a string variable s.  It then lists the records that match the search clause.
local match_list ""
foreach file in `files' {
	clear
	infix str s 1-200 using "`file'"
	gen l = strlen(s)
	egen m = max(l)
	assert (`=m' <= 200)
	
	//= Show which file this is, and what we're searching for.
	display "`file'"
	display `"`full_search'"'
	//= And now show the matches (there may be none).
	list s if (`full_search')
	display ""


	//= Since we may search a long list of files, but find few that have lines
	//= matching the search clause, build a list of files that match so we can 
	//= show it at the end.
	count if (`full_search')
	if (`r(N)' > 0) {
		local match_list "`match_list' `file'"
	}
}


//= Remind us what we were searching for.
display ""
display `"Search expression:  `full_search'"'

//= And show which, if any, files matched the search clause.
if (strlen("`match_list'") > 0) {
	local files_matched "Matched in:  `match_list'"
}
else {
	local files_matched "Not matched in any file"
}

display ""
display "`files_matched'"


//= Put the user back in the state they started.
restore

