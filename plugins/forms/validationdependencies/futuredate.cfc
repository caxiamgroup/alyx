<cfcomponent output="no" extends="_common">
<cfscript>

	function validate(required form, required params)
	{
		var local = {};

		local.fields = ArrayNew(1);

		if (StructKeyExists(arguments.params, "date"))
		{
			if (! IsDate(arguments.params.date))
			{
				// Date field validation should be completed elsewhere
				return;
			}

			local.date = arguments.params.date;
		}
		else
		{
			local.month = arguments.form.getFieldValue(arguments.params.month);
			local.year = arguments.form.getFieldValue(arguments.params.year);

			if (! IsNumeric(local.month) || local.month < 1 || local.month > 12 || ! IsNumeric(local.year))
			{
				// Individual date field validation should be completed elsewhere
				return;
			}

			ArrayAppend(local.fields, arguments.params.month);
			ArrayAppend(local.fields, arguments.params.year);

			if (StructKeyExists(arguments.params, "day"))
			{
				local.day = arguments.form.getFieldValue(arguments.params.day);

				if (! IsNumeric(local.day) || local.day < 1 || local.day > DaysInMonth(local.month & "/1/" & local.year))
				{
					// Individual date field validation should be completed elsewhere
					return;
				}

				ArrayAppend(local.fields, arguments.params.day);
			}
			else
			{
				local.day = DaysInMonth(local.month & "/1/" & local.year);
			}

			local.date = local.month & "/" & local.day & "/" & local.year;
		}

		if (StructKeyExists(arguments.params, "allowToday") && arguments.params.allowToday == false)
		{
			local.threshold = 1;
		}
		else
		{
			local.threshold = 0;
		}
		if (DateDiff("d", Now(), local.date) < local.threshold)
		{
			local.errorMsg = getErrorMessage("datefutureonly", arguments.params.errorMsg);
			local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", arguments.params.label);
			arguments.form.addError(local.errorMsg, local.fields);
		}
	}

	/* -------------------- Client Side Validation -------------------- */

	function getClientSideValidationScript(required form, required params, required context)
	{
		var local = {};

		if (! StructKeyExists(arguments.context.validationHelpers, "futuredate"))
		{
			arguments.context.validationHelpers.futuredate = "function validateFutureDate(form,date,year,month,day,allowToday,errorMsg){var yearValue;var monthValue;var dayValue;if(date){var dateValue=form.getValue(date);if(form.fieldHasErrors(date)||dateValue.length==0){return}dateValue=new Date(dateValue);yearValue=dateValue.getFullYear();monthValue=dateValue.getMonth()+1;dayValue=dateValue.getDate()}else{yearValue=parseInt(form.getValue(year),10);monthValue=parseInt(form.getValue(month),10);if(day){dayValue=parseInt(form.getValue(day),10)}else{dayValue=31}if(form.fieldHasErrors(year)||form.fieldHasErrors(month)||isNaN(yearValue)||isNaN(monthValue)||isNaN(dayValue)){return}}var thisDate=new Date();var thisYear=thisDate.getFullYear();var thisMonth=thisDate.getMonth()+1;var thisDay=thisDate.getDate();if((yearValue<thisYear)||(yearValue==thisYear&&monthValue<thisMonth)||(yearValue==thisYear&&monthValue==thisMonth&&(allowToday?dayValue<thisDay:dayValue<=thisDay))){form.addErrorMessages(errorMsg,[month,year])}}";
		}

		local.errorMsg = getErrorMessage("datefutureonly", arguments.params.errorMsg);
		local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", arguments.params.label);
		local.fields = ["date", "year", "month", "day"];
		for (local.field in local.fields)
		{
			if (StructKeyExists(arguments.params, local.field))
			{
				local[local.field] = "'" & arguments.params[local.field] & "'";
			}
			else
			{
				local[local.field] = "null";
			}
		}
		if (StructKeyExists(arguments.params, "allowToday") && arguments.params.allowToday == false)
		{
			local.allowToday = 0;
		}
		else
		{
			local.allowToday = 1;
		}
		arguments.context.output.append("validateFutureDate(this," & local.date & "," & local.year & "," & local.month & "," & local.day & "," & local.allowToday & ",'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');");
	}

</cfscript>
</cfcomponent>