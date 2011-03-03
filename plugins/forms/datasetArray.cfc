<cfcomponent name="DatasetArray" extends="dataset" output="no">
<cfscript>

	function getCount()
	{
		return ArrayLen(variables.data);
	}

	function getId(row = variables.currentRow)
	{
		return variables.data[arguments.row];
	}

	function getLabel(row = variables.currentRow)
	{
		return variables.data[arguments.row];
	}

</cfscript>
</cfcomponent>