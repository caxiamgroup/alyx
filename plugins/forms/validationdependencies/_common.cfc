<cfcomponent output="no">
<cfscript>

	function init()
	{
		return this;
	}

	private function getErrorMessage(required messageId, override = "")
	{
		var local = {};

		local.errorMsg = arguments.override;

		if (! Len(local.errorMsg))
		{
			local.errorMsg = application.controller.getPlugin("snippets").getSnippet(arguments.messageId, "errormessages");
		}

		return local.errorMsg;
	}

	private function getFieldLabels(required form, required fields)
	{
		var local = {};

		local.fieldLabels = "";
		local.numFields = ArrayLen(arguments.fields);

		for (local.fieldIndex = 1; local.fieldIndex <= local.numFields; ++local.fieldIndex)
		{
			local.field = arguments.form.getField(arguments.fields[local.fieldIndex]);

			if (local.fieldIndex == 1)
			{
				local.fieldLabels = local.field.label;
			}
			else
			{
				if (local.fieldIndex < local.numFields)
				{
					local.fieldLabels &= ", " & local.field.label;
				}
				else
				{
					local.fieldLabels &= " and " & local.field.label;
				}
			}
		}

		return local.fieldLabels;
	}

	/* -------------------- Client Side Validation -------------------- */

	function getClientSideValidationScript(required form, required params, required context)
	{
	}

</cfscript>
</cfcomponent>