<cfcomponent output="no" extends="string">

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif Len(arguments.value) and not IsValid("email", arguments.value)>
			<cfset local.errorMsg = getErrorMessage("emailbadformat", arguments.field)/>
			<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="clientCheckAllowedCharacters" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validateEmail")>
			<cfset arguments.context.validationHelpers.validateEmail = "function validateEmail(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;var tmpVar=value.split('@');if((tmpVar.length!=2)||(tmpVar[0].search(/^[-##-'\/-9A-Z^-{!*+?}~]$|^[-##-'\/-9A-Z^-{!*+?}~][-##-'\/-9A-Z^-{!*+.?}~]*[-##-'\/-9A-Z^-{!*+?}~]$/)!=0)||(tmpVar[1].search(/^[a-zA-Z0-9]([a-zA-Z0-9\.\_\-]*[a-zA-Z0-9])?\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/)!= 0)||(tmpVar[1].search(/\.{2}/)!=-1||tmpVar[1].search(/\_{2}/)!=-1||tmpVar[1].search(/\-{2}/)!=-1))form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("emailbadformat", arguments.field)/>
		<cfset arguments.context.output.append("validateEmail(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>