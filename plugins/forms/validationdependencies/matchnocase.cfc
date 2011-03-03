<cfcomponent output="no" extends="match">
<cfscript>

	private function getIgnoreCase()
	{
		return true;
	}

	/* -------------------- Client Side Validation -------------------- */

	function getClientSideValidationScript(required form, required params, required context)
	{
		var local = {};

		local.fields = ListToArray(arguments.params.fields);
		local.fieldLabels = getFieldLabels(arguments.form, local.fields);

		if (! StructKeyExists(arguments.context.validationHelpers, "matchNoCase"))
		{
			arguments.context.validationHelpers.matchNoCase = "function validateMatch(form,fields,errorMsg){fields=fields.split(',');var ref=form.getValue(fields[0]).toUpperCase();for(var i=1;i<fields.length;++i){if(form.getValue(fields[i]).toUpperCase()!=ref){form.addErrorMessages(errorMsg,fields);break;}}}";
		}

		local.errorMsg = getErrorMessage("mustmatch", arguments.params.errorMsg);
		local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabels);
		arguments.context.output.append("validateMatchNoCase(this,'" & arguments.params.fields & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>