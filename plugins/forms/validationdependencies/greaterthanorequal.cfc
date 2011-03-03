<cfcomponent output="no" extends="_common">
<cfscript>

	function validate(required form, required params)
	{
		var local = {};

		local.fields = ListToArray(arguments.params.fields);
		if (IsNumeric(arguments.form.getFieldValue(local.fields[1])) && IsNumeric(arguments.form.getFieldValue(local.fields[2]))
			&& arguments.form.getFieldValue(local.fields[1]) < arguments.form.getFieldValue(local.fields[2]))
		{
			local.errorMsg = getErrorMessage("greaterthanorequal", arguments.params.errorMsg);
			local.errorMsg = Replace(local.errorMsg, "%%fieldname1%%", arguments.form.getField(local.fields[1]).label);
			local.errorMsg = Replace(local.errorMsg, "%%fieldname2%%", arguments.form.getField(local.fields[2]).label);
			arguments.form.addError(local.errorMsg, local.fields);
		}
	}

	function getClientSideValidationScript(required form, required params, required context)
	{
		var local = {};

		local.fields = ListToArray(arguments.params.fields);

		if (! StructKeyExists(arguments.context.validationHelpers, "greaterthanorequalDep"))
		{
			arguments.context.validationHelpers.greaterthanorequalDep = "function validateGreaterThanOrEqual(form,fields,errorMsg){fields=fields.split(',');var value1=parseFloat(form.getValue(fields[0]));var value2=parseFloat(form.getValue(fields[1]));if(!isNaN(value1)&&!isNaN(value2)&&value1<value2){form.addErrorMessage(errorMsg,fields[0]);}}";
		}

		local.errorMsg = getErrorMessage("greaterthanorequal", arguments.params.errorMsg);
		local.errorMsg = Replace(local.errorMsg, "%%fieldname1%%", arguments.form.getField(local.fields[1]).label);
		local.errorMsg = Replace(local.errorMsg, "%%fieldname2%%", arguments.form.getField(local.fields[2]).label);
		arguments.context.output.append("validateGreaterThanOrEqual(this,'" & arguments.params.fields & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>