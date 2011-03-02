<cfcomponent output="no" extends="_common">

	<cffunction name="render" output="no">
		<cfargument name="field"    required="yes"/>
		<cfargument name="form"     required="yes"/>
		<cfargument name="extra"    default=""/>
		<cfargument name="value"    default="#arguments.form.getFieldValue(arguments.field.name)#"/>
		<cfargument name="id"       default="#arguments.field.name#-#arguments.value#"/>

		<cfset var local = StructNew()/>
		<cfset local.fieldName = arguments.form.getFieldName(arguments.field.name)/>

		<cfif ListFindNoCase(arguments.form.getFieldValue(arguments.field.name), arguments.value)>
			<cfset arguments.extra &= " checked=""checked"""/>
		</cfif>

		<cfif arguments.extra contains "class=""">
			<cfset arguments.extra = Replace(arguments.extra, "class=""", "class=""checkbox ")/>
		<cfelse>
			<cfset arguments.extra &= " class=""checkbox"""/>
		</cfif>

		<cfif Len(Trim(arguments.extra))>
			<cfset arguments.extra = " " & Trim(arguments.extra)/>
		</cfif>

		<cfreturn '<input type="checkbox" name="#local.fieldName#" id="#arguments.form.getName()#_#arguments.id#" value="#arguments.value#"#arguments.extra# />'/>
	</cffunction>

</cfcomponent>