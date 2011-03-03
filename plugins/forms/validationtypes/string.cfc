<cfcomponent output="no" extends="_common">
<cfscript>

	function doCustomValidations(field, value)
	{
		checkLength(argumentCollection = arguments);
		checkAllowedCharacters(argumentCollection = arguments);
	}

	function checkLength(field, value)
	{
		var local = {};

		if (StructKeyExists(arguments.field, "maxLength") && arguments.field.maxLength > 0)
		{
			if (Len(arguments.value) > arguments.field.maxLength)
			{
				local.errorMsg = getErrorMessage("maxlength", arguments.field);
				local.errorMsg = Replace(local.errorMsg, "%%maximum%%", arguments.field.maxLength);
				ArrayAppend(arguments.field.errors, local.errorMsg);
			}
		}

		if (StructKeyExists(arguments.field, "minLength") && arguments.field.minLength > 0)
		{
			if (Len(arguments.value) > 0 && Len(arguments.value) < arguments.field.minLength)
			{
				local.errorMsg = getErrorMessage("minlength", arguments.field);
				local.errorMsg = Replace(local.errorMsg, "%%minimum%%", arguments.field.minLength);
				ArrayAppend(arguments.field.errors, local.errorMsg);
			}
		}
	}

	function checkAllowedCharacters(field, value)
	{
		var local = {};

		// Filter out characters used in cross-site scripting
		if (Len(arguments.value) && REFind("[<>]", arguments.value) > 0)
		{
			local.errorMsg = getErrorMessage("invalidchars", arguments.field);
			ArrayAppend(arguments.field.errors, local.errorMsg);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	function clientDoCustomValidations(field, context)
	{
		clientCheckLength(argumentCollection = arguments);
		clientCheckAllowedCharacters(argumentCollection = arguments);
	}

	function clientCheckLength(field, context)
	{
		var local = {};

		if (StructKeyExists(arguments.field, "maxLength") && arguments.field.maxLength > 0)
		{
			local.errorMsg = getErrorMessage("maxlength", arguments.field);
			local.errorMsg = Replace(local.errorMsg, "%%maximum%%", arguments.field.maxLength);
			arguments.context.output.append("validateMaxLength(this,'" & arguments.field.name & "',#arguments.field.maxLength#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
		}

		if (StructKeyExists(arguments.field, "minLength") && arguments.field.minLength > 0)
		{
			local.errorMsg = getErrorMessage("minlength", arguments.field);
			local.errorMsg = Replace(local.errorMsg, "%%minimum%%", arguments.field.minLength);
			arguments.context.output.append("validateMinLength(this,'" & arguments.field.name & "',#arguments.field.minLength#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
		}
	}

	function clientCheckAllowedCharacters(field, context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "validateString"))
		{
			arguments.context.validationHelpers.validateString = "function validateString(form,field,errorMsg){if(form.getValue(field).search(/[<>]/)>=0)form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage("invalidchars", arguments.field);
		arguments.context.output.append("validateString(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>