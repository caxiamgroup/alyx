<cfcomponent output="no" extends="_common">

	<cffunction name="validate" output="no">
		<cfargument name="form"       required="yes"/>
		<cfargument name="params"     required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.field1 = ListFirst(arguments.params.fields)/>
		<cfif not Len(arguments.form.getFieldValue(local.field1))>
			<cfset local.count = 0/>
			<cfset local.fields = ListRest(arguments.params.fields)/>
			<cfset local.numFields = ListLen(local.fields)/>
			<cfif StructKeyExists(arguments.params, "value")>
				<cfset local.numValues = ListLen(arguments.params.value)/>
			<cfelse>
				<cfset local.numValues = -1/>
			</cfif>
			<cfloop from="1" to="#local.numFields#" index="local.index">
				<cfset local.field = ListGetAt(local.fields, local.index)/>

				<cfif
					(
						local.numValues eq -1 and
						Len(arguments.form.getFieldValue(local.field))
					)
					or
					(
						local.numValues eq 0 and
						not Len(arguments.form.getFieldValue(local.field))
					)
					or
					(
						local.numValues gte local.index and
						arguments.form.getFieldValue(local.field) eq ListGetAt(arguments.params.value, local.index)
					)
				>
					<cfset ++local.count/>
				</cfif>
			</cfloop>
			<cfif local.count eq local.numFields>
				<cfset local.fieldLabel = arguments.form.getField(local.field1).label/>

				<cfset local.errorMsg = getErrorMessage("required", arguments.params.errorMsg)/>
				<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabel)/>
				<cfset arguments.form.addError(local.errorMsg, local.field1)/>
			</cfif>
		</cfif>
	</cffunction>


	<cffunction name="getClientSideValidationScript" output="no">
		<cfargument name="form"    required="yes"/>
		<cfargument name="params"  required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.fields = ListToArray(arguments.params.fields)/>
		<cfset local.fieldLabel = arguments.form.getField(local.fields[1]).label/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "requiredDep")>
			<cfset arguments.context.validationHelpers.requiredDep = "function validateRequiredDep(form,fields,values,errorMsg){fields=fields.split(',');if(form.getValue(fields[0])==''){var numValues=-1;if(values!=null){if(values.length){values=values.split(',');numValues=values.length;}else{numValues=0;}}var field1=fields.shift();var numFields=fields.length;var count=0;for(var index=0;index<numFields;++index){var val=form.getValue(fields[index]);if(((numValues==-1)&&(val!=''))||((numValues==0)&&(val==''))||((numValues>=index)&&(val==values[index]))){++count;}}if(count==numFields){form.addErrorMessage(errorMsg,field1);}}}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("required", arguments.params.errorMsg)/>
		<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabel)/>
		<cfif StructKeyExists(arguments.params, "value")>
			<cfset local.value = "'" & JSStringFormat(HtmlEditFormat(arguments.params.value)) & "'"/>
		<cfelse>
			<cfset local.value = "null"/>
		</cfif>
		<cfset arguments.context.output.append("validateRequiredDep(this,'" & arguments.params.fields & "'," & local.value & ",'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>