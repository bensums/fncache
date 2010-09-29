## Very simple function value caching.
## Won't work for operations or other things more complicated than plain functions.
## Usage: 
## To enable caching of function named 'function':
##	CacheFunction(function);
##
## Warning: intended only for caching functions which take only integer arguments.

if not IsBound(Cache) then
	Cache := rec(
		 Functions := rec(),
		 Values := rec(),
	     	Save := function()
			local file;
			file := OutputTextFile("cache.txt", false);
			SetPrintFormattingStatus(file, false);
			AppendTo(file, String(Cache.Values));	
			CloseStream(file);
		      end,

	 );
fi;

## This function should return for each value of input a unique hash suitable for use as a component name (key?) in a record.
## The current version is only guaranteed to work when the input is a list of integers.
CacheHash := function(arg)
	return JoinStringsWithSeparator(List(arg, String), "_");
end;




## Use this to register a function for caching.
CacheFunction := function(f)
  	local fname;
	fname := NameFunction(f);
	# Move the function inside our cache thing.
	Cache.Functions.(fname) := f;
	# Place to store the values.
	Cache.Values.(fname) := rec();
	# Now we must overwrite the original function with our cache querying version.
	if IsReadOnlyGlobal(fname) then
		MakeReadWriteGlobal(fname);
      	fi;
	UnbindGlobal(fname);
	BindGlobal(fname,
		function(arg)
		  	# the key encodes the arguments.
		  	local key;
			key := CallFuncList(CacheHash, arg);
			if not IsBound(Cache.Values.(fname).(key)) then
			  	Cache.Values.(fname).(key) :=
					CallFuncList(Cache.Functions.(fname),
						arg);
		      	fi;
			return Cache.Values.(fname).(key);
		end
	);
	MakeReadWriteGlobal(fname);
end;

