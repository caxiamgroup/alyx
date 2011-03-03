<cfcomponent output="no" extends="string">
<cfscript>

	private function doCustomValidations(required field, required value)
	{
		/* Can't call super.doCustomValidations because we would lose context
		      and the call to checkAllowedCharacters would get scoped to the
		      wrong component for any components that extend this one. */

		checkRange(argumentCollection = arguments);
		checkLength(argumentCollection = arguments);
		checkAllowedCharacters(argumentCollection = arguments);
	}

	private function checkRange(required field, required value)
	{
		var local = {};

		if (! ArrayLen(arguments.field.errors) && Len(arguments.value))
		{
			if (StructKeyExists(arguments.field, "maxValue"))
			{
				if (arguments.value > arguments.field.maxValue)
				{
					local.errorMsg = getErrorMessage("maxvalue", arguments.field);
					local.errorMsg = Replace(local.errorMsg, "%%maximum%%", arguments.field.maxValue);
					ArrayAppend(arguments.field.errors, local.errorMsg);
				}
			}

			if (StructKeyExists(arguments.field, "minValue"))
			{
				if (arguments.value < arguments.field.minValue)
				{
					local.errorMsg = getErrorMessage("minvalue", arguments.field);
					local.errorMsg = Replace(local.errorMsg, "%%minimum%%", arguments.field.minValue);
					ArrayAppend(arguments.field.errors, local.errorMsg);
				}
			}
		}
	}

	private function checkAllowedCharacters(required field, required value)
	{
		var local = {};

		if (Len(arguments.value) && ! IsValid("numeric", arguments.value))
		{
			local.errorMsg = getErrorMessage("numericonly", arguments.field);
			ArrayAppend(arguments.field.errors, local.errorMsg);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	private function clientDoCustomValidations(required field, required context)
	{
		// See comments for corresponding server side validation.

		clientCheckRange(argumentCollection = arguments);
		clientCheckLength(argumentCollection = arguments);
		clientCheckAllowedCharacters(argumentCollection = arguments);
	}

	private function clientCheckRange(required field, required context)
	{
		var local = {};

		if (StructKeyExists(arguments.field, "maxValue"))
		{
			if (! StructKeyExists(arguments.context.validationHelpers, "maxValue"))
			{
				arguments.context.validationHelpers.maxValue = "function validateMaxValue(form,field,limit,errorMsg){var value=form.getValue(field);if(!value.length)return;if(value>limit)form.addErrorMessage(errorMsg,field);}";
			}

			local.errorMsg = getErrorMessage("maxvalue", arguments.field);
			local.errorMsg = Replace(local.errorMsg, "%%maximum%%", arguments.field.maxValue);
			arguments.context.output.append("validateMaxValue(this,'" & arguments.field.name & "',#arguments.field.maxValue#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
		}

		if (StructKeyExists(arguments.field, "minValue"))
		{
			if (! StructKeyExists(arguments.context.validationHelpers, "minValue"))
			{
				arguments.context.validationHelpers.minValue = "function validateMinValue(form,field,limit,errorMsg){var value=form.getValue(field);if(!value.length)return;if(value<limit)form.addErrorMessage(errorMsg,field);}";
			}

			local.errorMsg = getErrorMessage("minvalue", arguments.field);
			local.errorMsg = Replace(local.errorMsg, "%%minimum%%", arguments.field.minValue);
			arguments.context.output.append("validateMinValue(this,'" & arguments.field.name & "',#arguments.field.minValue#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
		}
	}

	private function clientCheckAllowedCharacters(required field, required context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "validateNumeric"))
		{
			arguments.context.validationHelpers.validateNumeric = "function validateNumeric(form,field,errorMsg){var value=form.getValue(field);if(value.search(/[^0-9.]/)>=0||value.search(/\..*\./)>=0)form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage("numericonly", arguments.field);
		arguments.context.output.append("validateNumeric(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>