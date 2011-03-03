<cfcomponent output="no" extends="_common">
<cfscript>

	variables.type = "text";

	function render(
		required field,
		required form,
		extra     = "",
		value     = arguments.form.getFieldValue(arguments.field.name)
	)
	{
		var local = {};

		local.fieldName = arguments.form.getFieldName(arguments.field.name);

		if (StructKeyExists(arguments, "size"))
		{
			arguments.extra &= " size=""" & arguments.size & """";
		}

		if (StructKeyExists(arguments.field, "maxLength"))
		{
			arguments.extra &= " maxlength=""" & arguments.field.maxLength & """";
		}

		if (Len(Trim(arguments.extra)))
		{
			arguments.extra = " " & Trim(arguments.extra);
		}

		arguments.value = formatValue(arguments.value);

		return '<input type="#variables.type#" name="#local.fieldName#" id="#local.fieldName#" value="#HtmlEditFormat(arguments.value)#"#arguments.extra# />';
	}

	private function formatValue(required value)
	{
		return arguments.value;
	}

</cfscript>
</cfcomponent>