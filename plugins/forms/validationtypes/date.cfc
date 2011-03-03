<cfcomponent output="no" extends="string">
<cfscript>

	private function checkAllowedCharacters(required field, required value)
	{
		var local = {};

		// TODO: Support locales other than "US". 'IsDate' allows time values.
		if (Len(arguments.value) && ! IsValid("USdate", arguments.value))
		{
			local.errorMsg = getErrorMessage("datebadformat", arguments.field);
			ArrayAppend(arguments.field.errors, local.errorMsg);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	private function clientCheckAllowedCharacters(required field, required context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "validateDate"))
		{
			arguments.context.validationHelpers.validateDate = "function validateDate(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;var exp=/^\d{1,2}\/\d{1,2}\/\d{4}$/;var valid=false;if(exp.test(value)){var a=value.split('/');var d=new Date(value);valid=(d.getMonth()+1==a[0]&&d.getDate()==a[1]&&d.getFullYear()==a[2]);}if(!valid)form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage("datebadformat", arguments.field);
		arguments.context.output.append("validateDate(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>