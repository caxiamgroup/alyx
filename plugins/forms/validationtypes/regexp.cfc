<cfcomponent output="no" extends="string">
<cfscript>

	variables.error = "invalidchars";

	private function checkAllowedCharacters(required field, required value)
	{
		var local = {};

		if (StructKeyExists(arguments.field, "regexp_cf"))
		{
			local.regexp = arguments.field.regexp_cf;
		}
		else if (StructKeyExists(arguments.field, "regexp"))
		{
			local.regexp = arguments.field.regexp;
		}
		else if (StructKeyExists(variables, "regexp_cf"))
		{
			local.regexp = variables.regexp_cf;
		}
		else if (StructKeyExists(variables, "regexp"))
		{
			local.regexp = variables.regexp;
		}
		else
		{
			throw(message = "Either 'regexp_cf' or 'regexp' must be defined");
		}

		if (Len(arguments.value) && REFind(local.regexp, arguments.value) == 0)
		{
			local.errorMsg = getErrorMessage(variables.error, arguments.field);
			ArrayAppend(arguments.field.errors, local.errorMsg);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	private function clientCheckAllowedCharacters(required field, required context)
	{
		var local = {};

		if (StructKeyExists(arguments.field, "regexp_js"))
		{
			local.regexp = arguments.field.regexp_js;
		}
		else if (StructKeyExists(arguments.field, "regexp"))
		{
			local.regexp = arguments.field.regexp;
		}
		else if (StructKeyExists(variables, "regexp_js"))
		{
			local.regexp = variables.regexp_js;
		}
		else if (StructKeyExists(variables, "regexp"))
		{
			local.regexp = variables.regexp;
		}
		else
		{
			throw(message = "Either 'regexp_js' or 'regexp' must be defined");
		}

		if (! StructKeyExists(arguments.context.validationHelpers, "validateRegExp"))
		{
			arguments.context.validationHelpers.validateRegExp = "function validateRegExp(form,field,regexp,errorMsg){var value=form.getValue(field);if(!value.length)return;var re=new RegExp(regexp);if(!value.match(re))form.addErrorMessage(errorMsg,field);}";
		}

		local.errorMsg = getErrorMessage(variables.error, arguments.field);
		arguments.context.output.append("validateRegExp(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.regexp)) & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>