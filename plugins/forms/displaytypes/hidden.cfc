<cfcomponent output="no" extends="_common">

	<cffunction name="render" output="no">
		<cfargument name="field"    required="yes"/>
		<cfargument name="form"     required="yes"/>
		<cfargument name="extra"    default=""/>
		<cfargument name="value"    default="#arguments.form.getFieldValue(arguments.field.name)#"/>

		<cfset var local = StructNew()/>
		<cfset local.fieldName = arguments.form.getFieldName(arguments.field.name)/>

		<cfif Len(Trim(arguments.extra))>
			<cfset arguments.extra = " " & Trim(arguments.extra)/>
		</cfif>

		<cfreturn '<input type="hidden" name="#local.fieldName#" id="#local.fieldName#" value="#HtmlEditFormat(arguments.value)#"#arguments.extra# />'/>
	</cffunction>

</cfcomponent>