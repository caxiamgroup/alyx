<cfcomponent output="no" extends="string">

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif Len(arguments.value) and not IsValid("creditcard", arguments.value)>
			<cfset local.errorMsg = getErrorMessage("cardnumberbadformat", arguments.field)/>
			<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="clientCheckAllowedCharacters" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validateCardNumber")>
			<cfset arguments.context.validationHelpers.validateCardNumber = "function validateCardNumber(form,field,errorMsg){var value=form.getValue(field);if(!value.length)return;if(value.search(/[^0-9,]/)>=0)form.addErrorMessage(errorMsg,field);var len=value.length;var parity=len%2;var total=0;for(var i=0;i<len;++i){var digit=value.charAt(i);if(i%2==parity){digit*=2;if(digit>9){digit-=9;}}total+=parseInt(digit);}if(total%10!=0)form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("cardnumberbadformat", arguments.field)/>
		<cfset arguments.context.output.append("validateCardNumber(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>