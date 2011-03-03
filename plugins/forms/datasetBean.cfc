<cfcomponent name="DatasetBean" extends="dataset" output="no">
<cfscript>

	function getCount()
	{
		return ArrayLen(variables.data);
	}

	function getId(row = variables.currentRow)
	{
		var value = evaluate("variables.data[arguments.row].get#variables.idField#()");
		return value;
	}

	function getLabel(row = variables.currentRow)
	{
		var value = evaluate("variables.data[arguments.row].get#variables.labelField#()");
		return value;
	}

</cfscript>
</cfcomponent>