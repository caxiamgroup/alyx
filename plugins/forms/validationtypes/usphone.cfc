<cfcomponent output="no" extends="string">
<cfscript>

	variables.regexp = "^(?:\([2-9]\d{2}\)\ ?|[2-9]\d{2}(?:\-?|\.\ ?))[2-9]\d{2}[-. ]?\d{4}$";

	private function checkAllowedCharacters(required field, required value)
	{
		var local = {};

		if (Len(arguments.value) && REFind(variables.regexp, arguments.value) == 0)
		{
			local.errorMsg = getErrorMessage("usphonebadformat", arguments.field);
			ArrayAppend(arguments.field.errors, local.errorMsg);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	private function clientCheckAllowedCharacters(required field, required context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "validateUsPhone"))
		{
			arguments.context.validationHelpers.validateUsPhone = "function validateUsPhone(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;if(value.search(/#variables.regexp#/)!=0)form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage("usphonebadformat", arguments.field);
		arguments.context.output.append("validateUsPhone(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>