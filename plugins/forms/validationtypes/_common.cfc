<cfcomponent output="no">

	<cffunction name="init" output="no">
		<cfreturn this/>
	</cffunction>

	<cffunction name="validate" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset validateRequired(argumentCollection = arguments)/>
		<cfset doCustomValidations(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="validateRequired" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif StructKeyExists(arguments.field, "required") and arguments.field.required is true>
			<cfif not Len(arguments.value)>
				<cfset local.errorMsg = getErrorMessage("required", arguments.field)/>
				<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getErrorMessage" output="no">
		<cfargument name="messageID" required="yes"/>
		<cfargument name="field"     required="yes"/>

		<cfset var local = StructNew()/>

		<cfif StructKeyExists(arguments.field, "errorMsg" & arguments.messageID)>
			<cfset local.errorMsg = arguments.field["errorMsg" & arguments.messageID]/>
		<cfelse>
			<cfset local.errorMsg = application.controller.getPlugin("snippets").getSnippet(arguments.messageID, "_errormessages")/>
		</cfif>
		<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", arguments.field.label)/>

		<cfreturn local.errorMsg/>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="getClientSideValidationScript" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset clientValidateRequired(argumentCollection = arguments)/>
		<cfset clientDoCustomValidations(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="clientValidateRequired" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif StructKeyExists(arguments.field, "required") and arguments.field.required is true>
			<!--- Moved to common validation.js file
			<cfif not StructKeyExists(arguments.context.validationHelpers, "required")>
				<cfset arguments.context.validationHelpers.required = "function validateRequired(form,field,errorMsg){if(!form.isNotRequired(field)&&form.getValue(field)=='')form.addErrorMessage(errorMsg,field);}"/>
			</cfif>
			--->

			<cfset local.errorMsg = getErrorMessage("required", arguments.field)/>
			<cfset arguments.context.output.append("validateRequired(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
		</cfif>
	</cffunction>
</cfcomponent>