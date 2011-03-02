<cfcomponent output="no" extends="_common">

	<cffunction name="render" output="no">
		<cfargument name="field"      required="yes"/>
		<cfargument name="form"       required="yes"/>
		<cfargument name="extra"      default=""/>
		<cfargument name="value"      default="#arguments.form.getFieldValue(arguments.field.name)#"/>
		<cfargument name="dataType"   default="dataset"/>
		<cfargument name="separator"  default="<br />"/>
		<cfargument name="labelExtra" default="class=""normal"""/>

		<cfset var local = StructNew()/>
		<cfset local.fieldName = arguments.form.getFieldName(arguments.field.name)/>
		<cfset local.output = ""/>

		<cfif arguments.extra contains "class=""">
			<cfset arguments.extra = Replace(arguments.extra, "class=""", "class=""radio ")/>
		<cfelse>
			<cfset arguments.extra &= " class=""radio"""/>
		</cfif>

		<cfif arguments.dataType eq "dataset" and StructKeyExists(arguments.field, "dataset")>
			<cfset arguments.field.dataset.rewind()/>
			<cfloop from="1" to="#arguments.field.dataset.getCount()#" index="local.row">
				<cfif arguments.separator eq "<li>" or local.row gt 1>
					<cfset local.output &= arguments.separator/>
				</cfif>
				<cfset local.id = arguments.field.dataset.getId(local.row)/>
				<cfset local.output &= '<input type="radio" name="#local.fieldName#" id="#local.fieldName#-#local.id#" value="#local.id#"#arguments.extra#'/>
				<cfif local.id eq arguments.value>
					<cfset local.output &= ' checked="checked"'/>
				</cfif>
				<cfset local.output &= ' /> ' & arguments.form.label(name = arguments.field.name, for = arguments.field.name & "-" & local.id, label = arguments.field.dataset.getLabel(local.row), required = false, extra = arguments.labelExtra)/>
				<cfif arguments.separator eq "<li>">
					<cfset local.output &= "</li>"/>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn local.output/>
	</cffunction>

</cfcomponent>