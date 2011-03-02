<cfcomponent output="no" extends="string">
	<cfset variables.error = "invalidchars"/>

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>
		
		<cfif StructKeyExists(arguments.field, "regexp_cf")>
			<cfset local.regexp = arguments.field.regexp_cf/>
		<cfelseif StructKeyExists(arguments.field, "regexp")>
			<cfset local.regexp = arguments.field.regexp/>
		<cfelseif StructKeyExists(variables, "regexp_cf")>
			<cfset local.regexp = variables.regexp_cf/>
		<cfelseif StructKeyExists(variables, "regexp")>
			<cfset local.regexp = variables.regexp/>
		<cfelse>
			<cfthrow message="Either 'regexp_cf' or 'regexp' must be defined"/>
		</cfif>

		<cfif Len(arguments.value) and REFind(local.regexp, arguments.value) eq 0>
			<cfset local.errorMsg = getErrorMessage(variables.error, arguments.field)/>
			<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="clientCheckAllowedCharacters" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif StructKeyExists(arguments.field, "regexp_js")>
			<cfset local.regexp = arguments.field.regexp_js/>
		<cfelseif StructKeyExists(arguments.field, "regexp")>
			<cfset local.regexp = arguments.field.regexp/>
		<cfelseif StructKeyExists(variables, "regexp_js")>
			<cfset local.regexp = variables.regexp_js/>
		<cfelseif StructKeyExists(variables, "regexp")>
			<cfset local.regexp = variables.regexp/>
		<cfelse>
			<cfthrow message="Either 'regexp_js' or 'regexp' must be defined"/>
		</cfif>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validateRegExp")>
			<cfset arguments.context.validationHelpers.validateRegExp = "function validateRegExp(form,field,regexp,errorMsg){var value=form.getValue(field);if(!value.length)return;var re=new RegExp(regexp);if(!value.match(re))form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage(variables.error, arguments.field)/>
		<cfset arguments.context.output.append("validateRegExp(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.regexp)) & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>