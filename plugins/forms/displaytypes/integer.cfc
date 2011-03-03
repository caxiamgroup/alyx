<cfcomponent output="no" extends="text">
<cfscript>

	private function formatValue(required value)
	{
		arguments.value = ReReplace(arguments.value, "[^0-9.-]", "", "all");
		if (IsNumeric(arguments.value))
		{
			arguments.value = NumberFormat(arguments.value, ",0");
		}
		return arguments.value;
	}

</cfscript>
</cfcomponent>