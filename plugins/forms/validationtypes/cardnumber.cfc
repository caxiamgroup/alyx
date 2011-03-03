<cfcomponent output="no" extends="string">
<cfscript>

	private function checkAllowedCharacters(required field, required value)
	{
		var local = {};

		if (Len(arguments.value) && ! IsValid("creditcard", arguments.value))
		{
			local.errorMsg = getErrorMessage("cardnumberbadformat", arguments.field);
			ArrayAppend(arguments.field.errors, local.errorMsg);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	private function clientCheckAllowedCharacters(required field, required context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "validateCardNumber"))
		{
			arguments.context.validationHelpers.validateCardNumber = "function validateCardNumber(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;if(value.search(/[^0-9,]/)>=0)form.addErrorMessage(errorMsg,field);var len=value.length;var parity=len%2;var total=0;for(var i=0;i<len;++i){var digit=value.charAt(i);if(i%2==parity){digit*=2;if(digit>9){digit-=9;}}total+=parseInt(digit);}if(total%10!=0)form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage("cardnumberbadformat", arguments.field);
		arguments.context.output.append("validateCardNumber(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>