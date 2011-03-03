<cfcomponent output="no" extends="_common">
<cfscript>

	function render(
		required field,
		required form,
		extra     = "",
		value     = arguments.form.getFieldValue(arguments.field.name)
	)
	{
		var local = {};

		local.fieldName = arguments.form.getFieldName(arguments.field.name);

		if (Len(Trim(arguments.extra)))
		{
			arguments.extra = " " & Trim(arguments.extra);
		}

		return '<input type="hidden" name="#local.fieldName#" id="#local.fieldName#" value="#HtmlEditFormat(arguments.value)#"#arguments.extra# />';
	}

</cfscript>
</cfcomponent>