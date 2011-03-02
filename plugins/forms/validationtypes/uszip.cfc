<cfcomponent output="no" extends="string">

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif Len(arguments.value) and not IsValid("zipcode", arguments.value)>
			<cfset local.errorMsg = getErrorMessage("uszipbadformat", arguments.field)/>
			<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="clientCheckAllowedCharacters" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validateUsZip")>
			<cfset arguments.context.validationHelpers.validateUsZip = "function validateUsZip(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;if((value.search(/^[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$/)!=0&&value.search(/^[0-9][0-9][0-9][0-9][0-9]$/)!=0))form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("uszipbadformat", arguments.field)/>
		<cfset arguments.context.output.append("validateUsZip(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>