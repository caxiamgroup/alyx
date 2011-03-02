<cfcomponent output="no" extends="_common">

	<cffunction name="doCustomValidations" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset checkLength(argumentCollection = arguments)/>
		<cfset checkAllowedCharacters(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="checkLength" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif StructKeyExists(arguments.field, "maxLength") and arguments.field.maxLength gt 0>
			<cfif Len(arguments.value) gt arguments.field.maxLength>
				<cfset local.errorMsg = getErrorMessage("maxlength", arguments.field)/>
				<cfset local.errorMsg = Replace(local.errorMsg, "%%maximum%%", arguments.field.maxLength)/>
				<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
			</cfif>
		</cfif>

		<cfif StructKeyExists(arguments.field, "minLength") and arguments.field.minLength gt 0>
			<cfif Len(arguments.value) gt 0 and Len(arguments.value) lt arguments.field.minLength>
				<cfset local.errorMsg = getErrorMessage("minlength", arguments.field)/>
				<cfset local.errorMsg = Replace(local.errorMsg, "%%minimum%%", arguments.field.minLength)/>
				<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<!--- Filter out characters used in cross-site scripting --->
		<cfif Len(arguments.value) and REFind("[<>]", arguments.value) gt 0>
			<cfset local.errorMsg = getErrorMessage("invalidchars", arguments.field)/>
			<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="clientDoCustomValidations" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset clientCheckLength(argumentCollection = arguments)/>
		<cfset clientCheckAllowedCharacters(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="clientCheckLength" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif StructKeyExists(arguments.field, "maxLength") and arguments.field.maxLength gt 0>
			<!--- Moved to common validation.js file
			<cfif not StructKeyExists(arguments.context.validationHelpers, "maxLength")>
				<cfset arguments.context.validationHelpers.maxLength = "function validateMaxLength(form,field,maxLength,errorMsg){if(form.getValue(field).length>maxLength)form.addErrorMessage(errorMsg,field);}"/>
			</cfif>
			--->

			<cfset local.errorMsg = getErrorMessage("maxlength", arguments.field)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%maximum%%", arguments.field.maxLength)/>
			<cfset arguments.context.output.append("validateMaxLength(this,'" & arguments.field.name & "',#arguments.field.maxLength#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
		</cfif>

		<cfif StructKeyExists(arguments.field, "minLength") and arguments.field.minLength gt 0>
			<!--- Moved to common validation.js file
			<cfif not StructKeyExists(arguments.context.validationHelpers, "minLength")>
				<cfset arguments.context.validationHelpers.minLength = "function validateMinLength(form,field,minLength,errorMsg){var length=form.getValue(field).length;if(length>0&&length<minLength)form.addErrorMessage(errorMsg,field);}"/>
			</cfif>
			--->

			<cfset local.errorMsg = getErrorMessage("minlength", arguments.field)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%minimum%%", arguments.field.minLength)/>
			<cfset arguments.context.output.append("validateMinLength(this,'" & arguments.field.name & "',#arguments.field.minLength#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
		</cfif>
	</cffunction>

	<cffunction name="clientCheckAllowedCharacters" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validateString")>
			<cfset arguments.context.validationHelpers.validateString = "function validateString(form,field,errorMsg){if(form.getValue(field).search(/[<>]/)>=0)form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("invalidchars", arguments.field)/>
		<cfset arguments.context.output.append("validateString(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>
</cfcomponent>