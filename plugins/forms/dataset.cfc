<cfcomponent name="Dataset" output="no" hint="Abstracts a data set for use in validating and displaying form fields.">
<cfscript>

	function init(
		required data,
		idField         = "id",
		labelField      = "label",
		groupIdField    = "",
		groupLabelField = ""
	)
	{
		variables.data = arguments.data;
		variables.idField = arguments.idField;
		variables.labelField = arguments.labelField;
		variables.groupIdField = arguments.groupIdField;
		variables.groupLabelField = arguments.groupLabelField;

		Rewind();

		return this;
	}

	function rewind()
	{
		variables.currentRow = 1;
	}

	function next()
	{
		++variables.currentRow;
	}

	function getData()
	{
		return variables.data;
	}

	function hasGroup()
	{
		return Len(variables.groupIdField) > 0;
	}

</cfscript>
</cfcomponent>