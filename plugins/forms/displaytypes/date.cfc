<cfcomponent output="no" extends="text">
<cfscript>

	function render(
		required field,
		required form,
		extra        = "",
		value        = arguments.form.getFieldValue(arguments.field.name),
		showCalendar = true
	)
	{
		if (arguments.showCalendar)
		{
			if (arguments.extra contains "class=""")
			{
				arguments.extra = Replace(arguments.extra, "class=""", "class=""dateinput ");
			}
			else
			{
				arguments.extra &= " class=""dateinput""";
			}
		}

		arguments.extra &= " data-value=""" & DateFormat(arguments.value, "yyyy-mm-dd") & """";

		return super.render(argumentCollection = arguments);
	}

	private function formatValue(required value)
	{
		if (IsDate(arguments.value))
		{
			arguments.value = DateFormat(arguments.value, "mm/dd/yyyy");
		}
		return arguments.value;
	}

</cfscript>
</cfcomponent>