<cfcomponent output="no" extends="string">

	<cffunction name="doCustomValidations" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<!--- Can't call super.doCustomValidations because we would lose context
		      and the call to checkAllowedCharacters would get scoped to the
		      wrong component for any components that extend this one. --->

		<cfset checkRange(argumentCollection = arguments)/>
		<cfset checkLength(argumentCollection = arguments)/>
		<cfset checkAllowedCharacters(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="checkRange" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not ArrayLen(arguments.field.errors) and Len(arguments.value)>
			<cfif StructKeyExists(arguments.field, "maxValue")>
				<cfif arguments.value gt arguments.field.maxValue>
					<cfset local.errorMsg = getErrorMessage("maxvalue", arguments.field)/>
					<cfset local.errorMsg = Replace(local.errorMsg, "%%maximum%%", arguments.field.maxValue)/>
					<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
				</cfif>
			</cfif>

			<cfif StructKeyExists(arguments.field, "minValue")>
				<cfif arguments.value lt arguments.field.minValue>
					<cfset local.errorMsg = getErrorMessage("minvalue", arguments.field)/>
					<cfset local.errorMsg = Replace(local.errorMsg, "%%minimum%%", arguments.field.minValue)/>
					<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
				</cfif>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif Len(arguments.value) and not IsValid("numeric", arguments.value)>
			<cfset local.errorMsg = getErrorMessage("numericonly", arguments.field)/>
			<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="clientDoCustomValidations" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<!--- See comments for corresponding server side validation. --->

		<cfset clientCheckRange(argumentCollection = arguments)/>
		<cfset clientCheckLength(argumentCollection = arguments)/>
		<cfset clientCheckAllowedCharacters(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="clientCheckRange" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif StructKeyExists(arguments.field, "maxValue")>
			<cfif not StructKeyExists(arguments.context.validationHelpers, "maxValue")>
				<cfset arguments.context.validationHelpers.maxValue = "function validateMaxValue(form,field,limit,errorMsg){var value=form.getValue(field);if(!value.length)return;if(value>limit)form.addErrorMessage(errorMsg,field);}"/>
			</cfif>

			<cfset local.errorMsg = getErrorMessage("maxvalue", arguments.field)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%maximum%%", arguments.field.maxValue)/>
			<cfset arguments.context.output.append("validateMaxValue(this,'" & arguments.field.name & "',#arguments.field.maxValue#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
		</cfif>

		<cfif StructKeyExists(arguments.field, "minValue")>
			<cfif not StructKeyExists(arguments.context.validationHelpers, "minValue")>
				<cfset arguments.context.validationHelpers.minValue = "function validateMinValue(form,field,limit,errorMsg){var value=form.getValue(field);if(!value.length)return;if(value<limit)form.addErrorMessage(errorMsg,field);}"/>
			</cfif>

			<cfset local.errorMsg = getErrorMessage("minvalue", arguments.field)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%minimum%%", arguments.field.minValue)/>
			<cfset arguments.context.output.append("validateMinValue(this,'" & arguments.field.name & "',#arguments.field.minValue#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
		</cfif>
	</cffunction>

	<cffunction name="clientCheckAllowedCharacters" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validateNumeric")>
			<cfset arguments.context.validationHelpers.validateNumeric = "function validateNumeric(form,field,errorMsg){var value=form.getValue(field);if(value.search(/[^0-9.]/)>=0||value.search(/\..*\./)>=0)form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("numericonly", arguments.field)/>
		<cfset arguments.context.output.append("validateNumeric(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>