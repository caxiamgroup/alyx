<cfcomponent name="Form" output="no">
<cfscript>

	function init(required name)
	{
		variables.rc = application.controller.getContext();
		variables.name = arguments.name;
		variables.errors = ArrayNew(1);
		variables.successMessage = "";
		variables.overrideSubmitted = false;
		variables.showClientSideValidationScript = true;
		variables.encType = "";
		variables.useFieldset = true;
		variables.errorHeading = application.controller.getPlugin("snippets").getSnippet("errorheading", "errormessages");
		resetFields();
		return this;
	}

	function getName()
	{
		return variables.name;
	}

	function resetFields()
	{
		variables.fields = {};
		variables.fieldOrder = ArrayNew(1);
		variables.fieldDependencies = ArrayNew(1);
	}

	function addField(
		required name,
		required label,
		required type,
		defaultValue  = ""
	)
	{
		var local = {};

		// Can't have an argument named "required" in CFScript.
		if (! StructKeyExists(arguments, "required"))
		{
			arguments.required = false;
		}

		local.field = Duplicate(arguments);

		local.field.dataset = "";

		variables.fields[arguments.name] = local.field;
		ArrayAppend(variables.fieldOrder, local.field);

		if (! StructKeyExists(variables.rc, getFieldName(arguments.name)))
		{
			variables.rc[getFieldName(arguments.name)] = arguments.defaultValue;
		}

		if (arguments.type == "file")
		{
			variables.encType = "multipart/form-data";
		}
	}

	function removeField(required name)
	{
		var local = {};

		if (StructKeyExists(variables.fields, arguments.name))
		{
			StructDelete(variables.fields, arguments.name);

			for (local.index = ArrayLen(variables.fieldOrder); local.index >= 1; --local.index)
			{
				if (variables.fieldOrder[local.index].name == arguments.name)
				{
					ArrayDeleteAt(variables.fieldOrder, local.index);
					break;
				}
			}
		}
	}

	function setFieldDataset(
		required name,
		data        = "",
		type        = "",
		delimiters  = ",",
		idField     = "id",
		labelField  = "label",
		dataset     = ""
	)
	{
		if (IsSimpleValue(arguments.dataset))
		{
			arguments.dataset = application.controller.getPlugin("forms").createDataset(argumentCollection = arguments);
		}

		variables.fields[arguments.name].dataset = arguments.dataset;
	}

	function getFieldDataset(required name)
	{
		return variables.fields[arguments.name].dataset;
	}

	function setFieldType(required name, type = "")
	{
		variables.fields[arguments.name].type = arguments.type;
	}

	function addDependency(
		required type,
		fields     = "",
		errorMsg   = ""
	)
	{
		ArrayAppend(variables.fieldDependencies, arguments);
	}

	function wasSubmitted()
	{
		return variables.overrideSubmitted || StructKeyExists(variables.rc, "form_" & variables.name);
	}

	function setSubmitted()
	{
		variables.overrideSubmitted = true;
	}

	function getFieldName(required name)
	{
		return variables.name & "_" & arguments.name;
	}

	function getFieldNames(regEx = "")
	{
		var local = {};
		local.fieldNames = "";

		for (local.field in variables.fieldOrder)
		{
			local.fieldName = local.field.name;
			if (! Len(arguments.regEx) || REFind(arguments.regEx, local.fieldName))
			{
				local.fieldNames = ListAppend(local.fieldNames, local.fieldName);
			}
		}

		return local.fieldNames;
	}

	function getFormFieldNames(regEx = "")
	{
		var local = {};
		local.fieldNames = "";

		local.prefixLen = Len(variables.name);

		for (local.fieldName in ListToArray(form.fieldNames))
		{
			if (Left(local.fieldName, local.prefixLen) == variables.name)
			{
				local.fieldName = RemoveChars(local.fieldName, 1, local.prefixLen + 1);
				if (! Len(arguments.regEx) || REFind(arguments.regEx, local.fieldName))
				{
					local.fieldNames = ListAppend(local.fieldNames, local.fieldName);
				}
			}
		}

		return local.fieldNames;
	}

	function getFieldValue(required name)
	{
		var value = "";
		var fieldName = getFieldName(arguments.name);
		if (StructKeyExists(variables.rc, fieldName))
		{
			value = Trim(variables.rc[fieldName]);
		}
		return value;
	}

	function setFieldValue(required name, required value)
	{
		variables.rc[getFieldName(arguments.name)] = arguments.value;
	}

	function fieldExists(required name)
	{
		return StructKeyExists(variables.fields, arguments.name);
	}

	function populateFromBean(required bean, prefix = "")
	{
		var local = {};
		for (local.field in variables.fieldOrder)
		{
			local.fieldName = local.field.name;
			if (Len(arguments.prefix))
			{
				local.fieldName = ReplaceNoCase(local.fieldName, arguments.prefix, "");
			}
			if (! StructKeyExists(arguments.bean, "get#local.fieldName#"))
			{
				// Field names such as "subscriber_firstName" are rewritten as "getSubscriberFirstName" in the model (without the underscore)
				local.fieldName = Replace(local.field.name, "_", "", "all");
				if (Len(arguments.prefix))
				{
					local.fieldName = ReplaceNoCase(local.fieldName, arguments.prefix, "");
				}
			}

			if (StructKeyExists(arguments.bean, "get#local.fieldName#"))
			{
				local.beanValue = evaluate("arguments.bean.get#local.fieldName#()");
				if (! StructKeyExists(local, "beanValue"))
				{
					local.beanValue = "";
				}
				setFieldValue(local.field.name, local.beanValue);
			}
		}
	}

	function populateBean(required bean, prefix = "")
	{
		var local = {};
		for (local.field in variables.fieldOrder)
		{
			local.fieldName = local.field.name;
			if (Len(arguments.prefix))
			{
				local.fieldName = ReplaceNoCase(local.fieldName, arguments.prefix, "");
			}
			if (! StructKeyExists(arguments.bean, "set#local.fieldName#"))
			{
				// Field names such as "subscriber_firstName" are rewritten as "setSubscriberFirstName" in the model (without the underscore)
				local.fieldName = Replace(local.field.name, "_", "", "all");
				if (Len(arguments.prefix))
				{
					local.fieldName = ReplaceNoCase(local.fieldName, arguments.prefix, "");
				}
			}

			if (StructKeyExists(arguments.bean, "set#local.fieldName#"))
			{
				local.fieldValue = getFieldValue(local.field.name);
				evaluate("arguments.bean.set#local.fieldName#(local.fieldValue)");
			}
		}
	}

	function validate()
	{
		var local = {};
		local.formsPlugin = application.controller.getPlugin("forms");
		variables.errors = ArrayNew(1);

		// Validate individual fields
		for (local.field in variables.fieldOrder)
		{
			local.validator = local.formsPlugin.getValidator(local.field.type);
			local.field.errors = ArrayNew(1);
			local.validator.validate(local.field, getFieldValue(local.field.name));
			for (local.error in local.field.errors)
			{
				ArrayAppend(variables.errors, local.error);
			}
		}

		// Validate field dependencies
		for (local.dependency in variables.fieldDependencies)
		{
			local.validator = local.formsPlugin.getDependencyValidator(local.dependency.type);
			local.validator.validate(this, local.dependency);
		}
	}

	function getFields()
	{
		return variables.fieldOrder;
	}

	function getField(required name)
	{
		return variables.fields[arguments.name];
	}

	function hasErrors()
	{
		return not ArrayIsEmpty(variables.errors);
	}

	function fieldHasErrors(required name)
	{
		return StructKeyExists(variables.fields[arguments.name], "errors") && ! ArrayIsEmpty(variables.fields[arguments.name].errors);
	}

	function getErrors()
	{
		return variables.errors;
	}

	function setErrors(required errors)
	{
		variables.errors = arguments.errors;
	}

	function hasSuccessMessage()
	{
		return Len(variables.successMessage);
	}

	function getSuccessMessage()
	{
		return variables.successMessage;
	}

	function setSuccessMessage(required successMessage)
	{
		variables.successMessage = arguments.successMessage;
	}

	function start(
		action       = request.context.action,
		method       = "post",
		extra        = "",
		autocomplete = "",
		onSubmit     = "return validateForm(this)",
        useFieldset  = variables.useFieldset
	)
	{
		variables.useFieldset = arguments.useFieldset;

		if (!FindNoCase(".cfm", arguments.action))
		{
			if (ListFirst(arguments.action,".") == "general")
			{
				arguments.action = ListRest(arguments.action, ".");
			}
			arguments.action = "/" & ListChangeDelims(arguments.action, "/", ".") & ".cfm";
		}

		if (arguments.autocomplete == false)
		{
			arguments.extra &= " autocomplete=""off""";
		}

		if (Len(arguments.onSubmit))
		{
			arguments.extra &= " onsubmit=""" & arguments.onSubmit & """";
		}

		if (Len(variables.encType))
		{
			arguments.extra &= " enctype=""" & variables.encType & """";
		}

		if (Len(Trim(arguments.extra)))
		{
			arguments.extra = " " & Trim(arguments.extra);
		}

		variables.started = true;

		local.result = "<form action=""#arguments.action#"" id=""#variables.name#"" method=""#arguments.method#""#arguments.extra#>";

		if (variables.useFieldset)
		{
			local.result &= "<fieldset>";
		}

		local.result &= "<input type=""hidden"" name=""form_#variables.name#"" value=""""/>";

		return local.result;
	}

	function end()
	{
		var formEnd = "</form>";

		if (variables.useFieldset)
		{
			formEnd = "</fieldset>" & formEnd;
		}

		return formEnd;
	}

	function isStarted()
	{
		return StructKeyExists(variables, "started") && variables.started == true;
	}

	function label(
		required name,
		label          = variables.fields[ListFirst(arguments.name)].label,
		id             = "",
		extra          = "",
		errorClass     = "",
		requiredClass  = "",
		beforeLabel    = "",
		afterLabel     = ""
	)
	{
		var local = {};

		// Can't have an argument named "required" in CFScript.
		if (! StructKeyExists(arguments, "required"))
		{
			arguments.required = variables.fields[ListFirst(arguments.name)].required;
		}

		// Can't have an argument named "for" in CFScript.
		if (! StructKeyExists(arguments, "for"))
		{
			arguments.for = ListFirst(arguments.name);
		}

		local.hasErrors = false;
		local.classes = "";

		for (local.fieldName in ListToArray(arguments.name))
		{
			local.field = variables.fields[local.fieldName];
			if (StructKeyExists(local.field, "errors") && ArrayLen(local.field.errors))
			{
				local.hasErrors = true;
				break;
			}
		}

		local.fieldId = variables.name & "_" & arguments.for;

		if (local.hasErrors)
		{
			if (! Len(arguments.errorClass))
			{
				 arguments.errorClass = application.controller.getSetting("formFieldErrorClass", "error");
			}

			if (Len(arguments.errorClass))
			{
				local.classes &= " " & arguments.errorClass;
			}
		}

		if (Len(arguments.id))
		{
			if (IsBoolean(arguments.id) && arguments.id == true)
			{
				arguments.extra &= " id=""label-" & local.fieldId & """";
			}
			else
			{
				arguments.extra &= " id=""" & arguments.id & """";
			}
		}

		if (arguments.required)
		{
			if (! Len(arguments.requiredClass))
			{
				arguments.requiredClass = application.controller.getSetting("formFieldRequiredClass", "required");
			}
			local.classes &= " " & arguments.requiredClass;
		}

		if (Len(local.classes))
		{
			if (FindNoCase("class=", arguments.extra))
			{
				arguments.extra = Replace(arguments.extra, "class=""", "class=""" & Trim(local.classes) & " ");
			}
			else
			{
				arguments.extra &= " class=""" & Trim(local.classes) & """";
			}
		}

		if (Len(Trim(arguments.extra)))
		{
			arguments.extra = " " & Trim(arguments.extra);
		}

		local.output = "<label for=""#local.fieldId#""#arguments.extra#>#arguments.beforeLabel##arguments.label##arguments.afterLabel#</label>";

		return local.output;
	}

	function addError(required error, fields = "")
	{
		var local = {};

		ArrayAppend(variables.errors, arguments.error);
		if (IsArray(arguments.fields))
		{
			for (local.fieldName in arguments.fields)
			{
				ArrayAppend(variables.fields[local.fieldName].errors, arguments.error);
			}
		}
		else
		{
			for (local.fieldName in ListToArray(arguments.fields))
			{
				ArrayAppend(variables.fields[local.fieldName].errors, arguments.error);
			}
		}
	}

	// Add error messages from another form object.
	function addErrors(required errors)
	{
		var local = {};

		for (local.error in arguments.errors)
		{
			ArrayAppend(variables.errors, local.error);
		}
	}

	function displayErrors(
		title = variables.errorHeading,
		open  = "",
		close = ""
	)
	{
		var local = {};

		local.output = "<div id=""error-message-#getName()#"">";
		if (hasErrors())
		{
			local.output &= "<div class=""msg error"">" & arguments.open;
			if (Len(arguments.title))
			{
				local.output &= "<p>" & arguments.title & "</p>";
			}
			local.output &= "<ul>";
			for (local.error in variables.errors)
			{
				local.output &= "<li>#local.error#</li>";
			}
			local.output &= "</ul>" & arguments.close & "</div>";
		}
		local.output &= "</div>";

		return local.output;
	}

	function displaySuccessMessage(open = "", close = "")
	{
		var local = {};

		local.output = "";
		if (hasSuccessMessage())
		{
			local.output = '<div class="msg success">' & arguments.open;
			local.output &= "<ul><li>" & getSuccessMessage() & "</li></ul>";
			local.output &= arguments.close & '</div>';
		}

		return local.output;
	}

	function displayMessages(
		errorTitle   = variables.errorHeading,
		errorOpen    = "",
		errorClose   = "",
		successOpen  = "",
		successClose = ""
	)
	{
		var local = {};

		if (hasSuccessMessage())
		{
			local.output = displaySuccessMessage(open = arguments.successOpen, close = arguments.successClose);
		}
		else
		{
			local.output = displayErrors(title = arguments.errorTitle, open = arguments.errorOpen, close = arguments.errorClose);
		}

		return local.output;
	}

	function renderField(
		required name,
		required type,
		field = variables.fields[arguments.name],
		form = this
	)
	{
		var renderer = application.controller.getPlugin("forms").getRenderer(arguments.type);
		return renderer.render(argumentCollection = arguments);
	}

	function setShowClientSideValidationScript(required show)
	{
		variables.showClientSideValidationScript = arguments.show;
	}

	function getShowClientSideValidationScript()
	{
		return variables.showClientSideValidationScript && ArrayLen(variables.fieldOrder) > 0;
	}

	function getClientSideValidationScript(required context)
	{
		var local = {};
		local.formsPlugin = application.controller.getPlugin("forms");
		// Validate field dependencies
		for (local.dependency in variables.fieldDependencies)
		{
			local.validator = local.formsPlugin.getDependencyValidator(local.dependency.type);
			local.validator.getClientSideValidationScript(this, local.dependency, arguments.context);
		}
	}

	// Creates a structure of field names and their values. Does not store field type or validation info.
	function serialize()
	{
		var local = {};
		local.data = {};
		for (local.field in variables.fieldOrder)
		{
			local.data[local.field.name] = getFieldValue(local.field.name);
		}
		return local.data;
	}

	// Restores field values from a previous 'serialize' operation.
	function deserialize(required data)
	{
		var field = "";
		for (field in arguments.data)
		{
			if (StructKeyExists(variables.fields, field))
			{
				setFieldValue(field, arguments.data[field]);
			}
		}
	}

	/* ---------------Private Functions --------------- */

	function OnMissingMethod(
		required missingMethodName,
		required missingMethodArguments
	)
	{
		if (CompareNoCase(Left(arguments.missingMethodName, 6), "render") == 0)
		{
			arguments.missingMethodArguments.type = Right(arguments.missingMethodName, Len(arguments.missingMethodName) - 6);
			return renderField(argumentCollection = arguments.missingMethodArguments);
		}

		return "";
	}

</cfscript>
</cfcomponent>