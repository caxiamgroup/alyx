<cfcomponent name="DatasetQuery" extends="dataset" output="no">
<cfscript>

	function getCount()
	{
		return variables.data.recordcount;
	}

	function getId(row = variables.currentRow)
	{
		return variables.data[variables.idField][arguments.row];
	}

	function getLabel(row = variables.currentRow)
	{
		return variables.data[variables.labelField][arguments.row];
	}

	function getGroupId(row = variables.currentRow)
	{
		return variables.data[variables.groupIdField][arguments.row];
	}

	function getGroupLabel(row = variables.currentRow)
	{
		return variables.data[variables.groupLabelField][arguments.row];
	}

</cfscript>
</cfcomponent>