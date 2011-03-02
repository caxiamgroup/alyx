<cfcomponent output="no">

	<cffunction name="init" output="no">
		<cfreturn this/>
	</cffunction>

	<cffunction name="getErrorMessage" access="private" output="no">
		<cfargument name="messageID" required="yes"/>
		<cfargument name="override"  default=""/>

		<cfset var local = StructNew()/>
		<cfset local.errorMsg = arguments.override/>

		<cfif not Len(local.errorMsg)>
			<cfset local.errorMsg = application.controller.getPlugin("snippets").getSnippet(arguments.messageID, "errormessages")/>
		</cfif>

		<cfreturn local.errorMsg/>
	</cffunction>

	<cffunction name="getFieldLabels" access="private" output="no">
		<cfargument name="form"   required="yes"/>
		<cfargument name="fields" required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.fieldLabels = ""/>
		<cfset local.numFields = ArrayLen(arguments.fields)/>

		<cfloop from="1" to="#local.numFields#" index="local.fieldIndex">
			<cfset local.field = arguments.form.getField(arguments.fields[local.fieldIndex])/>

			<cfif local.fieldIndex eq 1>
				<cfset local.fieldLabels = local.field.label/>
			<cfelse>
				<cfif local.fieldIndex lt local.numFields>
					<cfset local.fieldLabels &= ", " & local.field.label/>
				<cfelse>
					<cfset local.fieldLabels &= " and " & local.field.label/>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn local.fieldLabels/>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="getClientSideValidationScript" output="no">
		<cfargument name="form"    required="yes"/>
		<cfargument name="params"  required="yes"/>
		<cfargument name="context" required="yes"/>
	</cffunction>

</cfcomponent>