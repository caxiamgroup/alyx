<cfcomponent output="no" extends="_common">

	<cffunction name="render" output="no">
		<cfargument name="field"    required="yes"/>
		<cfargument name="form"     required="yes"/>
		<cfargument name="rows"     default="3"/>
		<cfargument name="cols"     default="25"/>
		<cfargument name="extra"    default=""/>

		<cfset var local = StructNew()/>
		<cfset local.fieldName = arguments.form.getFieldName(arguments.field.name)/>

		<cfif Len(Trim(arguments.extra))>
			<cfset arguments.extra = " " & Trim(arguments.extra)/>
		</cfif>

		<cfreturn '<textarea rows="#arguments.rows#" cols="#arguments.cols#" name="#local.fieldName#" id="#local.fieldName#"#arguments.extra#>#arguments.form.getFieldValue(arguments.field.name)#</textarea>'/>
	</cffunction>
</cfcomponent>