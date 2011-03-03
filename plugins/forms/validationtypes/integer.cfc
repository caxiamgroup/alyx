<cfcomponent output="no" extends="numeric">
<cfscript>

	private function checkAllowedCharacters(required field, required value)
	{
		var local = {};

		if (Len(arguments.value) && ReFind("[^0-9,]", arguments.value) != 0)
		{
			local.errorMsg = getErrorMessage("integeronly", arguments.field);
			ArrayAppend(arguments.field.errors, local.errorMsg);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	private function clientCheckAllowedCharacters(required field, required context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "validateInteger"))
		{
			arguments.context.validationHelpers.validateInteger = "function validateInteger(form,field,errorMsg){if(form.getValue(field).search(/[^0-9,]/)>=0)form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage("integeronly", arguments.field);
		arguments.context.output.append("validateInteger(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>