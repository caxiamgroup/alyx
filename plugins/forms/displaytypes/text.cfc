<cfcomponent output="no" extends="_common">
	<cfset variables.type = "text"/>

	<cffunction name="render" output="no">
		<cfargument name="field"    required="yes"/>
		<cfargument name="form"     required="yes"/>
		<cfargument name="extra"    default=""/>
		<cfargument name="value"    default="#arguments.form.getFieldValue(arguments.field.name)#"/>

		<cfset var local = StructNew()/>
		<cfset local.fieldName = arguments.form.getFieldName(arguments.field.name)/>

		<cfif StructKeyExists(arguments, "size")>
			<cfset arguments.extra &= " size=""" & arguments.size & """"/>
		</cfif>

		<cfif StructKeyExists(arguments.field, "maxLength")>
			<cfset arguments.extra &= " maxlength=""" & arguments.field.maxLength & """"/>
		</cfif>

		<cfif Len(Trim(arguments.extra))>
			<cfset arguments.extra = " " & Trim(arguments.extra)/>
		</cfif>

		<cfset arguments.value = formatValue(arguments.value)/>

		<cfreturn '<input type="#variables.type#" name="#local.fieldName#" id="#local.fieldName#" value="#HtmlEditFormat(arguments.value)#"#arguments.extra# />'/>
	</cffunction>

	<cffunction name="formatValue" access="private" output="false">
		<cfargument name="value" required="yes"/>
		<cfreturn arguments.value/>
	</cffunction>

</cfcomponent>