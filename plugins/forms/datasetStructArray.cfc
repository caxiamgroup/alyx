<cfcomponent name="DatasetStructArray" extends="dataset" output="no">
<cfscript>

	function getCount()
	{
		return ArrayLen(variables.data);
	}

	function getId(row = variables.currentRow)
	{
		return variables.data[arguments.row][variables.idField];
	}

	function getLabel(row = variables.currentRow)
	{
		return variables.data[arguments.row][variables.labelField];
	}

</cfscript>
</cfcomponent>