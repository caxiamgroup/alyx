<cfcomponent output="no" extends="string">

	<cfset variables.type = "Decimal"/>

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
			<cfset local.value = ReReplace(arguments.value, "[^0-9.-]", "", "all")/>
			<cfif IsNumeric(local.value)>
				<cfif StructKeyExists(arguments.field, "maxValue")>
					<cfif local.value gt arguments.field.maxValue>
						<cfset local.errorMsg = getErrorMessage("maxvalue", arguments.field)/>
						<cfset local.errorMsg = Replace(local.errorMsg, "%%maximum%%", NumberFormat(arguments.field.maxValue, ",0.00"))/>
						<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
					</cfif>
				</cfif>
	
				<cfif StructKeyExists(arguments.field, "minValue")>
					<cfif local.value lt arguments.field.minValue>
						<cfset local.errorMsg = getErrorMessage("minvalue", arguments.field)/>
						<cfset local.errorMsg = Replace(local.errorMsg, "%%minimum%%", NumberFormat(arguments.field.minValue, ",0.00"))/>
						<cfset ArrayAppend(arguments.field.errors, local.errorMsg)/>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="checkAllowedCharacters" access="private" output="no">
		<cfargument name="field" required="yes"/>
		<cfargument name="value" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif Len(arguments.value) and ReFind("[^0-9,.-]", arguments.value)>
			<cfset local.errorMsg = getErrorMessage(variables.type & "only", arguments.field)/>
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
			<cfif not StructKeyExists(arguments.context.validationHelpers, "max" & variables.type)>
				<cfset arguments.context.validationHelpers["max" & variables.type] = "function validateMax" & variables.type & "(form,field,limit,errorMsg){var value=new String(form.getValue(field));value=value.replace(/[^0-9-.]/g,'');if(!value.length)return;if(parseFloat(value)>limit)form.addErrorMessage(errorMsg,field);}"/>
			</cfif>

			<cfset local.errorMsg = getErrorMessage("maxvalue", arguments.field)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%maximum%%", NumberFormat(arguments.field.maxValue, ",0.00"))/>
			<cfset arguments.context.output.append("validateMax" & variables.type & "(this,'" & arguments.field.name & "',#arguments.field.maxValue#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
		</cfif>

		<cfif StructKeyExists(arguments.field, "minValue")>
			<cfif not StructKeyExists(arguments.context.validationHelpers, "min" & variables.type)>
				<cfset arguments.context.validationHelpers["min" & variables.type] = "function validateMin" & variables.type & "(form,field,limit,errorMsg){var value=new String(form.getValue(field));value=value.replace(/[^0-9-.]/g,'');if(!value.length)return;if(parseFloat(value)<limit)form.addErrorMessage(errorMsg,field);}"/>
			</cfif>

			<cfset local.errorMsg = getErrorMessage("minvalue", arguments.field)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%minimum%%", NumberFormat(arguments.field.minValue, ",0.00"))/>
			<cfset arguments.context.output.append("validateMin" & variables.type & "(this,'" & arguments.field.name & "',#arguments.field.minValue#,'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
		</cfif>
	</cffunction>

	<cffunction name="clientCheckAllowedCharacters" access="private" output="no">
		<cfargument name="field"   required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "validate" & variables.type)>
			<cfset arguments.context.validationHelpers["validate" & variables.type] = "function validate" & variables.type & "(form,field,errorMsg){var value=form.getValue(field);if(value.search(/[^0-9-.,]/)>=0||value.search(/\..*\./)>=0)form.addErrorMessage(errorMsg,field);}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage(variables.type & "only", arguments.field)/>
		<cfset arguments.context.output.append("validate" & variables.type & "(this,'" & arguments.field.name & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>