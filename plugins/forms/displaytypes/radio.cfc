<cfcomponent output="no" extends="_common">
<cfscript>

	function render(
		required field,
		required form,
		extra     = "",
		value     = arguments.form.getFieldValue(arguments.field.name),
		id        = "#arguments.field.name#-#arguments.value#"
	)
	{
		var local = {};

		local.fieldName = arguments.form.getFieldName(arguments.field.name);

		if (arguments.form.getFieldValue(arguments.field.name) == arguments.value)
		{
			arguments.extra &= " checked=""checked""";
		}

		if (arguments.extra contains "class=""")
		{
			arguments.extra = Replace(arguments.extra, "class=""", "class=""radio ");
		}
		else
		{
			arguments.extra &= " class=""radio""";
		}

		if (Len(Trim(arguments.extra)))
		{
			arguments.extra = " " & Trim(arguments.extra);
		}

		return '<input type="radio" name="#local.fieldName#" id="#arguments.form.getName()#_#arguments.id#" value="#arguments.value#"#arguments.extra# />';
	}

</cfscript>
</cfcomponent>