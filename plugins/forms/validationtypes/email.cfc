<cfcomponent output="no" extends="string">
<cfscript>

	private function checkAllowedCharacters(required field, required value)
	{
		var local = {};

		if (Len(arguments.value) && ! IsValid("email", arguments.value))
		{
			local.errorMsg = getErrorMessage("emailbadformat", arguments.field);
			ArrayAppend(arguments.field.errors, local.errorMsg);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	private function clientCheckAllowedCharacters(required field, required context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "validateEmail"))
		{
			arguments.context.validationHelpers.validateEmail = "function validateEmail(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;var tmpVar=value.split('@');if((tmpVar.length!=2)||(tmpVar[0].search(/^[-##-'\/-9A-Z^-{!*+?}~]$|^[-##-'\/-9A-Z^-{!*+?}~][-##-'\/-9A-Z^-{!*+.?}~]*[-##-'\/-9A-Z^-{!*+?}~]$/)!=0)||(tmpVar[1].search(/^[a-zA-Z0-9]([a-zA-Z0-9\.\_\-]*[a-zA-Z0-9])?\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/)!= 0)||(tmpVar[1].search(/\.{2}/)!=-1||tmpVar[1].search(/\_{2}/)!=-1||tmpVar[1].search(/\-{2}/)!=-1))form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage("emailbadformat", arguments.field);
		arguments.context.output.append("validateEmail(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>