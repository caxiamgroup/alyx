<cfcomponent output="no" extends="string">

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<!--- TODO: Support locales other than "US". 'IsDate' allows time values. --->
		<cfif Len(arguments.value) and not IsValid("USdate", arguments.value)>
			<cfset local.errorMsg = getErrorMessage("datebadformat", arguments.field)/>
			<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="clientCheckAllowedCharacters" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validateDate")>
			<cfset arguments.context.validationHelpers.validateDate = "function validateDate(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;var exp=/^\d{1,2}\/\d{1,2}\/\d{4}$/;var valid=false;if(exp.test(value)){var a=value.split('/');var d=new Date(value);valid=(d.getMonth()+1==a[0]&&d.getDate()==a[1]&&d.getFullYear()==a[2]);}if(!valid)form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("datebadformat", arguments.field)/>
		<cfset arguments.context.output.append("validateDate(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>