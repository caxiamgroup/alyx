<cfcomponent output="no" extends="nomatch">

	<cffunction name="getIgnoreCase" access="private" output="no">
		<cfreturn true/>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="getClientSideValidationScript" output="no">
		<cfargument name="form"    required="yes"/>
		<cfargument name="params"  required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.fields = ListToArray(arguments.params.fields)/>
		<cfset local.fieldLabels = getFieldLabels(arguments.form, local.fields)/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "noMatchNoCase")>
			<cfset arguments.context.validationHelpers.noMatchNoCase = "function validateNoMatch(form,fields,errorMsg){fields=fields.split(',');var ref=form.getValue(fields[0]).toUpperCase();if(!ref.length)return;for(var i=1;i<fields.length;++i){if(form.getValue(fields[i]).toUpperCase()==ref){form.addErrorMessages(errorMsg,fields);break;}}}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("mustnotmatch", arguments.params.errorMsg)/>
		<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabels)/>
		<cfset arguments.context.output.append("validateNoMatchNoCase(this,'" & arguments.params.fields & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>