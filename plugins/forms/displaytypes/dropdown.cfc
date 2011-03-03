<cfcomponent output="no" extends="_common">
<cfscript>

	function render(
		required field,
		required form,
		extra            = "",
		value            = arguments.form.getFieldValue(arguments.field.name),
		dataType         = "dataset",
		firstEmpty       = true,
		firstOption      = "",
		firstOptionValue = "",
		id               = "#arguments.form.getFieldName(arguments.field.name)#"
	)
	{
		var local = {};

		local.fieldName = arguments.form.getFieldName(arguments.field.name);
		local.hasDataset = arguments.dataType == "dataset" && StructKeyExists(arguments.field, "dataset") && ! IsSimpleValue(arguments.field.dataset);

		if (Len(Trim(arguments.extra)))
		{
			arguments.extra = " " & Trim(arguments.extra);
		}

		if (Len(arguments.firstOption))
		{
			local.options = '<option value="' & arguments.firstOptionValue & '">' & arguments.firstOption & '</option>';
		}
		else if (! IsBoolean(arguments.firstEmpty))
		{
			 if (local.hasDataset && arguments.field.dataset.getCount() == 1)
			 {
				/* If there is only one option, don't add empty first option */
				local.options = '';
			}
			else
			{
				local.options = '<option value="">&nbsp;</option>';
			}
		}
		else if (arguments.firstEmpty == true)
		{
			local.options = '<option value="">&nbsp;</option>';
		}
		else
		{
			local.options = '';
		}

		if (local.hasDataset)
		{
			arguments.field.dataset.rewind();

			if (arguments.field.dataset.hasGroup())
			{
				local.lastGroupId = "";
				local.rowCount = arguments.field.dataset.getCount();
				for (local.row = 1; local.row <= local.rowCount; ++local.row)
				{
					local.groupId = arguments.field.dataset.getGroupId(local.row);
					if (local.groupId != local.lastGroupId)
					{
						if (Len(local.lastGroupId))
						{
							local.options &= '</optgroup>';
						}
						local.options &= '<optgroup label="' & arguments.field.dataset.getGroupLabel(local.row) & '">';
						local.lastGroupId = local.groupId;
					}
					local.id = arguments.field.dataset.getId(local.row);
					local.options &= '<option value="#local.id#"';
					if (local.id == arguments.value)
					{
						local.options &= ' selected="selected"';
					}
					local.options &= '>' & arguments.field.dataset.getLabel(local.row) & '&nbsp;&nbsp;</option>';
				}
				if (Len(local.lastGroupId))
				{
					local.options &= '</optgroup>';
				}
			}
			else
			{
				local.rowCount = arguments.field.dataset.getCount();
				for (local.row = 1; local.row <= local.rowCount; ++local.row)
				{
					local.id = arguments.field.dataset.getId(local.row);
					local.options &= '<option value="#local.id#"';
					if (local.id == arguments.value)
					{
						local.options &= ' selected="selected"';
					}
					local.options &= '>' & arguments.field.dataset.getLabel(local.row) & '</option>';
				}
			}

		}

		return '<select name="#local.fieldName#" id="#arguments.id#"#arguments.extra#>' & local.options & '</select>';
	}

</cfscript>
</cfcomponent>