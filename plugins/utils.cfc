<cfcomponent>
<cfscript>

	function safeDollarFormat(required value, defaultValue = arguments.value)
	{
		if (IsNumeric(arguments.value))
		{
			return DollarFormat(arguments.value);
		}
		return arguments.defaultValue;
	}

	function safeDecimalFormat(required value, defaultValue = arguments.value)
	{
		if (IsNumeric(arguments.value))
		{
			return NumberFormat(arguments.value, ",0.00");
		}
		return arguments.defaultValue;
	}

	function safeNumberFormat(required value, defaultValue = arguments.value)
	{
		if (IsNumeric(arguments.value))
		{
			return NumberFormat(arguments.value, ",0");
		}
		return arguments.defaultValue;
	}

	function safeDateFormat(required value, format = "mm/dd/yyyy", defaultValue = arguments.value)
	{
		if (IsDate(arguments.value))
		{
			return DateFormat(arguments.value, arguments.format);
		}
		return arguments.defaultValue;
	}

	function extractNumber(required value, defaultValue = arguments.value)
	{
		var local = {};

		local.results = arguments.defaultValue;
		local.value = ReReplace(arguments.value, "[^0-9.-]", "", "all");
		if (Len(local.value) && IsNumeric(local.value))
		{
			local.results = local.value;
		}

		return local.results;
	}

	function extractDecimal(required value, defaultValue = arguments.value)
	{
		var local = {};

		local.results = arguments.defaultValue;
		local.value = ReReplace(arguments.value, "[^0-9.-]", "", "all");
		if (Len(local.value) && IsNumeric(local.value))
		{
			local.results = NumberFormat(local.value, "0.00");
		}

		return local.results;
	}

	function tableFormat(value)
	{
		value = Trim(value);
		if (not Len(value))
		{
			value = "&nbsp;";
		}
		return value;
	}

	function phoneFormat(value)
	{
		var numArgs = ArrayLen(arguments);
		var tmpValue = "";
		var newValue = "";
		var maskPos = 1;
		var valuePos = 1;
		var c = "";
		var maskLen = "";
		var valueLen = "";
		var mask = "xxx-xxx-xxxx";

		if (numArgs >= 2 && Len(Trim(arguments[2])))
		{
			mask = Trim(arguments[2]);
		}

		tmpValue = ReReplace(value, "[^A-Za-z0-9]", "", "all");

		if (Len(tmpValue) <= 11 && Len(tmpValue) >= 7)
		{
			maskLen = Len(mask);
			mask = Reverse(mask);
			tmpValue = Reverse(tmpValue);
			valueLen = Len(tmpValue);

			for (maskPos = 1; maskPos <= maskLen && valuePos <= valueLen; ++maskPos)
			{
				c = Mid(mask, maskPos, 1);
				if (c == "x")
				{
					newValue = newValue & Mid(tmpValue, valuePos, 1);
					valuePos = valuePos + 1;
				}
				else
				{
					newValue = newValue & c;
				}
			}
			// Special case for closing grouping symbol
			if (maskPos == maskLen)
			{
				newValue = newValue & Mid(mask, maskPos, 1);
			}
			newValue = Reverse(newValue);
		}
		else
		{
			newValue = value;
		}

		return Trim(newValue);
	}

	function emailFormat(value)
	{
		value = Trim(value);
		if (Len(value) && IsValid("email", value))
		{
			value = "<a href=""mailto:" & value & """>" & value & "</a>";
		}
		return value;
	}

	function formatDay(value)
	{
		var suffix = "th";
		switch (value)
		{
			case 1:
			case 21:
			case 31:
				suffix = "st";
				break;
			case 2:
			case 22:
				suffix = "nd";
				break;
			case 3:
			case 23:
				suffix = "rd";
				break;
		}
		return value & suffix;
	}

	function addressFormat(
		addressLine1 = "",
		addressLine2 = "",
		city = "",
		state = "",
		zipCode = ""
	)
	{
		var address = "";

		if (Len(arguments.addressLine1))
		{
			if (Len(address))
			{
				address &= "<br />";
			}
			address &= arguments.addressLine1;
		}

		if (Len(arguments.addressLine2))
		{
			if (Len(address))
			{
				address &= "<br />";
			}
			address &= arguments.addressLine2;
		}

		if (Len(arguments.city) || Len(arguments.state) || Len(arguments.zipCode))
		{
			if (Len(address))
			{
				address &= "<br />";
			}

			if (Len(arguments.city))
			{
				address &= arguments.city;

				if (Len(arguments.state))
				{
					address &= ", ";
				}
			}

			if (Len(arguments.state))
			{
				address &= arguments.state;
			}

			if (Len(arguments.zipCode))
			{
				if (Len(arguments.city) or Len(arguments.state))
				{
					address &= "&nbsp;&nbsp;";
				}

				address &= arguments.zipCode;
			}
		}

		return address;
	}

	function displayErrors(open = "", close = "")
	{
		var local = {};

		local.output = "";

		if (! StructKeyExists(arguments, "errors") && StructKeyExists(request.context, "errors"))
		{
			arguments.errors = request.context.errors;
		}

		if (StructKeyExists(arguments, "errors") && IsArray(arguments.errors) && ! ArrayIsEmpty(arguments.errors))
		{
			local.output = arguments.open & "<div class=""error"">The following problems were found:</div><ul class=""error"">";
			for (local.error in arguments.errors)
			{
				local.output &= "<li>#local.error#</li>";
			}
			local.output &= "</ul>" & arguments.close;
		}

		return local.output;
	}

	function getForm(required name)
	{
		return application.controller.getPlugin("forms").getForm(arguments.name);
	}

	function queryToArray(required data, startRow = "", endRow = "")
	{
		var local = {};

		local.columns = ListToArray(arguments.data.columnList);
		local.converted = [];
		local.numRows = arguments.data.recordCount;

		arguments.startRow = Min(Max(Val(arguments.startRow), 1), local.numRows);
		arguments.endRow = Min(Max(Val(arguments.endRow), 1), local.numRows);

		// Not calling queryToStruct in inner loop for performance reasons

		for (local.rowIndex = arguments.startrow; local.rowIndex <= arguments.endrow; ++local.rowIndex)
		{
			local.row = {};

			for (local.column in local.columns)
			{
				local.row[local.column] = arguments.data[local.column][local.rowIndex];
			}

			ArrayAppend(local.converted, local.row);

		}

		return local.converted;
	}

	function queryToStruct(required data, rowIndex = 1)
	{
		var local = {};

		local.columns = ListToArray(arguments.data.columnList);
		local.row = {};

		if (arguments.data.recordCount >= arguments.rowIndex)
		{
			for (local.column in local.columns)
			{
				local.row[local.column] = arguments.data[local.column][arguments.rowIndex];
			}
		}
		else
		{
			for (local.column in local.columns)
			{
				local.row[local.column] = "";
			}
		}

		return local.row;
	}

</cfscript>
</cfcomponent>