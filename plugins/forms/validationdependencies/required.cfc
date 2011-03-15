<cfcomponent output="no" extends="_common">
<cfscript>

	function validate(required form, required params)
	{
		var local = {};

		local.field1 = ListFirst(arguments.params.fields);
		if (! Len(arguments.form.getFieldValue(local.field1)))
		{
			local.count = 0;
			local.fields = ListRest(arguments.params.fields);
			local.numFields = ListLen(local.fields);
			if (StructKeyExists(arguments.params, "value"))
			{
				local.numValues = ListLen(arguments.params.value);
			}
			else
			{
				local.numValues = -1;
			}
			for (local.index = 1; local.index <= local.numFields; ++local.index)
			{
				local.field = ListGetAt(local.fields, local.index);

				if (
					(
						local.numValues == -1 &&
						Len(arguments.form.getFieldValue(local.field))
					)
					or
					(
						local.numValues == 0 &&
						! Len(arguments.form.getFieldValue(local.field))
					)
					or
					(
						local.numValues >= local.index &&
						arguments.form.getFieldValue(local.field) == ListGetAt(arguments.params.value, local.index)
					)
				)
				{
					++local.count;
				}
			}
			if (local.count == local.numFields)
			{
				local.fieldLabel = arguments.form.getField(local.field1).label;

				local.errorMsg = getErrorMessage("required", arguments.params.errorMsg);
				local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabel);
				arguments.form.addError(local.errorMsg, local.field1);
			}
		}
	}


	function getClientSideValidationScript(required form, required params, required context)
	{
		var local = {};

		local.fields = ListToArray(arguments.params.fields);
		local.fieldLabel = arguments.form.getField(local.fields[1]).label;

		if (! StructKeyExists(arguments.context.validationHelpers, "requiredDep"))
		{
			arguments.context.validationHelpers.requiredDep = "function validateRequiredDep(form,fields,values,errorMsg){fields=fields.split(',');if(form.getValue(fields[0])==''){var numValues=-1;if(values!=null){if(values.length){values=values.split(',');numValues=values.length;}else{numValues=0;}}var field1=fields.shift();var numFields=fields.length;var count=0;for(var index=0;index<numFields;++index){var val=form.getValue(fields[index]);if(((numValues==-1)&&(val!=''))||((numValues==0)&&(val==''))||((numValues>=index)&&(val==values[index]))){++count;}}if(count==numFields){form.addErrorMessage(errorMsg,field1);}}}";
		}

		local.errorMsg = getErrorMessage("required", arguments.params.errorMsg);
		local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabel);
		if (StructKeyExists(arguments.params, "value"))
		{
			local.value = "'" & JSStringFormat(HtmlEditFormat(arguments.params.value)) & "'";
		}
		else
		{
			local.value = "null";
		}
		arguments.context.output.append("validateRequiredDep(this,'" & arguments.params.fields & "'," & local.value & ",'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>