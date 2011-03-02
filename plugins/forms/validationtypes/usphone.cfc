<cfcomponent output="no" extends="string">
	<cfset variables.regexp = "^(?:\([2-9]\d{2}\)\ ?|[2-9]\d{2}(?:\-?|\.\ ?))[2-9]\d{2}[-. ]?\d{4}$"/>

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif Len(arguments.value) and REFind(variables.regexp, arguments.value) eq 0>
			<cfset local.errorMsg = getErrorMessage("usphonebadformat", arguments.field)/>
			<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="clientCheckAllowedCharacters" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validateUsPhone")>
			<cfset arguments.context.validationHelpers.validateUsPhone = "function validateUsPhone(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;if(value.search(/#variables.regexp#/)!=0)form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("usphonebadformat", arguments.field)/>
		<cfset arguments.context.output.append("validateUsPhone(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>