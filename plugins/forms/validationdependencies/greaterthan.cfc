<cfcomponent output="no" extends="_common">

	<cffunction name="validate" output="no">
		<cfargument name="form"       required="yes"/>
		<cfargument name="params"     required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.fields = ListToArray(arguments.params.fields)/>
		<cfif IsNumeric(arguments.form.getFieldValue(local.fields[1])) and IsNumeric(arguments.form.getFieldValue(local.fields[2]))
			and arguments.form.getFieldValue(local.fields[1]) lte arguments.form.getFieldValue(local.fields[2])>
			<cfset local.errorMsg = getErrorMessage("greaterthan", arguments.params.errorMsg)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname1%%", arguments.form.getField(local.fields[1]).label)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname2%%", arguments.form.getField(local.fields[2]).label)/>
			<cfset arguments.form.addError(local.errorMsg, local.fields)/>
		</cfif>
	</cffunction>

	<cffunction name="getClientSideValidationScript" output="no">
		<cfargument name="form"    required="yes"/>
		<cfargument name="params"  required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.fields = ListToArray(arguments.params.fields)/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "greaterthanDep")>
			<cfset arguments.context.validationHelpers.greaterthanDep = "function validateGreaterThanDep(form,fields,errorMsg){fields=fields.split(',');var value1=parseFloat(form.getValue(fields[0]));var value2=parseFloat(form.getValue(fields[1]));if(!isNaN(value1)&&!isNaN(value2)&&value1<=value2){form.addErrorMessage(errorMsg,fields[0]);}}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("greaterthan", arguments.params.errorMsg)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname1%%", arguments.form.getField(local.fields[1]).label)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname2%%", arguments.form.getField(local.fields[2]).label)/>
		<cfset arguments.context.output.append("validateGreaterThanDep(this,'" & arguments.params.fields & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>