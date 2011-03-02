<cfcomponent output="no" extends="numeric">

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif Len(arguments.value) and ReFind("[^0-9,]", arguments.value) neq 0>
			<cfset local.errorMsg = getErrorMessage("integeronly", arguments.field)/>
			<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="clientCheckAllowedCharacters" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validateInteger")>
			<cfset arguments.context.validationHelpers.validateInteger = "function validateInteger(form,field,errorMsg){if(form.getValue(field).search(/[^0-9,]/)>=0)form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("integeronly", arguments.field)/>
		<cfset arguments.context.output.append("validateInteger(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>