<cfcomponent output="no" extends="_common">
<cfscript>

	function validate(required form, required params)
	{
		var local = {};

		local.fields = ListToArray(arguments.params.fields);
		local.refFieldValue = arguments.form.getFieldValue(local.fields[1]);
		local.fieldLabels = arguments.form.getField(local.fields[1]).label;
		local.allMatch = true;
		local.numFields = ArrayLen(local.fields);

		for (local.fieldIndex = 1; local.fieldIndex <= local.numFields; ++local.fieldIndex)
		{
			local.field = arguments.form.getField(local.fields[local.fieldIndex]);

			if (ArrayLen(local.field.errors))
			{
				// Skip dependency checking if any fields already have an error
				local.allMatch = true;
				break;
			}

			local.fieldValue = arguments.form.getFieldValue(local.field.name);

			if (local.fieldIndex == 1)
			{
				local.fieldLabels = local.field.label;
				local.refFieldValue = local.fieldValue;
			}
			else
			{
				if (local.fieldIndex < local.numFields)
				{
					local.fieldLabels &= ", " & local.field.label;
				}
				else
				{
					local.fieldLabels &= " and " & local.field.label;
				}

				if (getIgnoreCase())
				{
					local.matchResults = CompareNoCase(local.fieldValue, local.refFieldValue);
				}
				else
				{
					local.matchResults = Compare(local.fieldValue, local.refFieldValue);
				}

				if (local.matchResults != 0)
				{
					local.allMatch = false;
					break;
				}
			}
		}

		if (! local.allMatch)
		{
			local.errorMsg = getErrorMessage("mustmatch", arguments.params.errorMsg);
			local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabels);
			arguments.form.addError(local.errorMsg, local.fields);
		}
	}

	private function getIgnoreCase()
	{
		return false;
	}

	/* -------------------- Client Side Validation -------------------- */

	function getClientSideValidationScript(required form, required params, required context)
	{
		var local = {};

		local.fields = ListToArray(arguments.params.fields);
		local.fieldLabels = getFieldLabels(arguments.form, local.fields);

		if (! StructKeyExists(arguments.context.validationHelpers, "match"))
		{
			arguments.context.validationHelpers.match = "function validateMatch(form,fields,errorMsg){fields=fields.split(',');var ref=form.getValue(fields[0]);for(var i=1;i<fields.length;++i){if(form.getValue(fields[i])!=ref){form.addErrorMessages(errorMsg,fields);break;}}}";
		}

		local.errorMsg = getErrorMessage("mustmatch", arguments.params.errorMsg);
		local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabels);
		arguments.context.output.append("validateMatch(this,'" & arguments.params.fields & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>