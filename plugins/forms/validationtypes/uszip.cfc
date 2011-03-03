<cfcomponent output="no" extends="string">
<cfscript>

	private function checkAllowedCharacters(required field, required value)
	{
		var local = {};

		if (Len(arguments.value) && ! IsValid("zipcode", arguments.value))
		{
			local.errorMsg = getErrorMessage("uszipbadformat", arguments.field);
			ArrayAppend(arguments.field.errors, local.errorMsg);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	private function clientCheckAllowedCharacters(required field, required context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "validateUsZip"))
		{
			arguments.context.validationHelpers.validateUsZip = "function validateUsZip(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;if((value.search(/^[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$/)!=0&&value.search(/^[0-9][0-9][0-9][0-9][0-9]$/)!=0))form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage("uszipbadformat", arguments.field);
		arguments.context.output.append("validateUsZip(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>