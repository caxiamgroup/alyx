<cfcomponent output="no" extends="text">
<cfscript>

	function render(required field, size = 10, showCalendar = true)
	{
		var local = {};
		local.output = super.render(argumentCollection = arguments);
		if (arguments.showCalendar)
		{
			local.id = arguments.form.getFieldName(arguments.field.name);
			local.output &= ' <a href="javascript:;" onclick="calSelect(this);return false;" name="calbtn-#local.id#" id="calbtn-#local.id#" title="Click for calendar"><img src="/_media/icons/calendar.gif" alt="Click for calendar" style="vertical-align:middle;" /></a>';
		}

		return local.output;

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