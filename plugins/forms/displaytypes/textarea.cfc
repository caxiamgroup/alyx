<cfcomponent output="no" extends="_common">
<cfscript>

	function render(
		required field,
		required form,
		extra     = "",
		rows      = 3,
		cols      = 25
	)
	{
		var local = {};

		local.fieldName = arguments.form.getFieldName(arguments.field.name);

		if (Len(Trim(arguments.extra)))
		{
			arguments.extra = " " & Trim(arguments.extra);
		}

		return '<textarea rows="#arguments.rows#" cols="#arguments.cols#" name="#local.fieldName#" id="#local.fieldName#"#arguments.extra#>#arguments.form.getFieldValue(arguments.field.name)#</textarea>';
	}

</cfscript>
</cfcomponent>