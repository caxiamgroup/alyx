<cfcomponent output="no" extends="_common">
<cfscript>

	function render(
		required field,
		required form,
		extra      = "",
		value      = arguments.form.getFieldValue(arguments.field.name),
		dataType   = "dataset",
		separator  = "<br />",
		labelExtra = "class=""normal"""
	)
	{
		var local = {};

		local.fieldName = arguments.form.getFieldName(arguments.field.name);
		local.output = "";

		if (arguments.extra contains "class=""")
		{
			arguments.extra = Replace(arguments.extra, "class=""", "class=""radio ");
		}
		else
		{
			arguments.extra &= " class=""radio""";
		}

		if (arguments.dataType == "dataset" && StructKeyExists(arguments.field, "dataset"))
		{
			arguments.field.dataset.rewind();
			local.rowCount = arguments.field.dataset.getCount();
			for (local.row = 1; local.row <= local.rowCount; ++local.row)
			{
				if (arguments.separator == "<li>" || local.row > 1)
				{
					local.output &= arguments.separator;
				}
				local.id = arguments.field.dataset.getId(local.row);
				local.output &= '<input type="radio" name="#local.fieldName#" id="#local.fieldName#-#local.id#" value="#local.id#"#arguments.extra#';
				if (local.id == arguments.value)
				{
					local.output &= ' checked="checked"';
				}
				// CFScript is treating the "for" key as a reserved word (for loops) when used as an argument to a function.
				local.labelArguments = {
					name = arguments.field.name,
					label = arguments.field.dataset.getLabel(local.row),
					required = false,
					extra = arguments.labelExtra
				};
				local.labelArguments.for = arguments.field.name & "-" & local.id;
				local.output &= ' /> ' & arguments.form.label(argumentCollection = local.labelArguments);
				if (arguments.separator == "<li>")
				{
					local.output &= "</li>";
				}
			}
		}

		return local.output;
	}

</cfscript>
</cfcomponent>