<cfcomponent output="no" extends="string">
<cfscript>

	variables.type = "Decimal";

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
			local.value = ReReplace(arguments.value, "[^0-9.-]", "", "all");
			if (IsNumeric(local.value))
			{
				if (StructKeyExists(arguments.field, "maxValue"))
				{
					if (local.value > arguments.field.maxValue)
					{
						local.errorMsg = getErrorMessage("maxvalue", arguments.field);
						local.errorMsg = Replace(local.errorMsg, "%%maximum%%", NumberFormat(arguments.field.maxValue, ",0.00"));
						ArrayAppend(arguments.field.errors, local.errorMsg);
					}
				}

				if (StructKeyExists(arguments.field, "minValue"))
				{
					if (local.value < arguments.field.minValue)
					{
						local.errorMsg = getErrorMessage("minvalue", arguments.field);
						local.errorMsg = Replace(local.errorMsg, "%%minimum%%", NumberFormat(arguments.field.minValue, ",0.00"));
						ArrayAppend(arguments.field.errors, local.errorMsg);
					}
				}
			}
		}
	}

	private function checkAllowedCharacters(required field, required value)
	{
		var local = {};

		if (Len(arguments.value) && ReFind("[^0-9,.-]", arguments.value))
		{
			local.errorMsg = getErrorMessage(variables.type & "only", arguments.field);
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
			if (! StructKeyExists(arguments.context.validationHelpers, "max" & variables.type))
			{
				arguments.context.validationHelpers["max" & variables.type] = "function validateMax" & variables.type & "(form,field,limit,errorMsg){var value=new String(form.getValue(field));value=value.replace(/[^0-9-.]/g,'');if(!value.length)return;if(parseFloat(value)>limit)form.addErrorMessage(errorMsg,field);}";
			}

			local.errorMsg = getErrorMessage("maxvalue", arguments.field);
			local.errorMsg = Replace(local.errorMsg, "%%maximum%%", NumberFormat(arguments.field.maxValue, ",0.00"));
			arguments.context.output.append("validateMax" & variables.type & "(this,'" & arguments.field.name & "',#arguments.field.maxValue#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
		}

		if (StructKeyExists(arguments.field, "minValue"))
		{
			if (! StructKeyExists(arguments.context.validationHelpers, "min" & variables.type))
			{
				arguments.context.validationHelpers["min" & variables.type] = "function validateMin" & variables.type & "(form,field,limit,errorMsg){var value=new String(form.getValue(field));value=value.replace(/[^0-9-.]/g,'');if(!value.length)return;if(parseFloat(value)<limit)form.addErrorMessage(errorMsg,field);}";
			}

			local.errorMsg = getErrorMessage("minvalue", arguments.field);
			local.errorMsg = Replace(local.errorMsg, "%%minimum%%", NumberFormat(arguments.field.minValue, ",0.00"));
			arguments.context.output.append("validateMin" & variables.type & "(this,'" & arguments.field.name & "',#arguments.field.minValue#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
		}
	}

	private function clientCheckAllowedCharacters(required field, required context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "validate" & variables.type))
		{
			arguments.context.validationHelpers["validate" & variables.type] = "function validate" & variables.type & "(form,field,errorMsg){var value=form.getValue(field);if(value.search(/[^0-9-.,]/)>=0||value.search(/\..*\./)>=0)form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage(variables.type & "only", arguments.field);
		arguments.context.output.append("validate" & variables.type & "(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>