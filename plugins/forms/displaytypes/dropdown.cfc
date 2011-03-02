<cfcomponent output="no" extends="_common">

	<cffunction name="render" output="no">
		<cfargument name="field"            required="yes"/>
		<cfargument name="form"             required="yes"/>
		<cfargument name="extra"            default=""/>
		<cfargument name="value"            default="#arguments.form.getFieldValue(arguments.field.name)#"/>
		<cfargument name="dataType"         default="dataset"/>
		<cfargument name="firstEmpty"       default="true"/>
		<cfargument name="firstOption"      default=""/>
		<cfargument name="firstOptionValue" default=""/>
		<cfargument name="id"               default="#arguments.form.getFieldName(arguments.field.name)#"/>

		<cfset var local = StructNew()/>
		<cfset local.fieldName = arguments.form.getFieldName(arguments.field.name)/>
		<cfset local.hasDataset = arguments.dataType eq "dataset" and StructKeyExists(arguments.field, "dataset") and not IsSimpleValue(arguments.field.dataset)/>

		<cfif Len(Trim(arguments.extra))>
			<cfset arguments.extra = " " & Trim(arguments.extra)/>
		</cfif>

		<cfif Len(arguments.firstOption)>
			<cfset local.options = '<option value="' & arguments.firstOptionValue & '">' & arguments.firstOption & '</option>'/>
		<cfelseif not IsBoolean(arguments.firstEmpty)>
			 <cfif local.hasDataset and arguments.field.dataset.getCount() eq 1>
				<!--- If there is only one option, don't add empty first option --->
				<cfset local.options = ''/>
			<cfelse>
				<cfset local.options = '<option value="">&nbsp;</option>'/>
			</cfif>
		<cfelseif arguments.firstEmpty eq true>
			<cfset local.options = '<option value="">&nbsp;</option>'/>
		<cfelse>
			<cfset local.options = ''/>
		</cfif>

		<cfif local.hasDataset>
			<cfset arguments.field.dataset.rewind()/>

			<cfif arguments.field.dataset.hasGroup()>
				<cfset local.lastGroupId = ""/>
				<cfloop from="1" to="#arguments.field.dataset.getCount()#" index="local.row">
					<cfset local.groupId = arguments.field.dataset.getGroupId(local.row)/>
					<cfif local.groupId neq local.lastGroupId>
						<cfif Len(local.lastGroupId)>
							<cfset local.options &= '</optgroup>'/>
						</cfif>
						<cfset local.options &= '<optgroup label="' & arguments.field.dataset.getGroupLabel(local.row) & '">'/>
						<cfset local.lastGroupId = local.groupId/>
					</cfif>
					<cfset local.id = arguments.field.dataset.getId(local.row)/>
					<cfset local.options &= '<option value="#local.id#"'/>
					<cfif local.id eq arguments.value>
						<cfset local.options &= ' selected="selected"'/>
					</cfif>
					<cfset local.options &= '>' & arguments.field.dataset.getLabel(local.row) & '&nbsp;&nbsp;</option>'/>
				</cfloop>
				<cfif Len(local.lastGroupId)>
					<cfset local.options &= '</optgroup>'/>
				</cfif>
			<cfelse>
				<cfloop from="1" to="#arguments.field.dataset.getCount()#" index="local.row">
					<cfset local.id = arguments.field.dataset.getId(local.row)/>
					<cfset local.options &= '<option value="#local.id#"'/>
					<cfif local.id eq arguments.value>
						<cfset local.options &= ' selected="selected"'/>
					</cfif>
					<cfset local.options &= '>' & arguments.field.dataset.getLabel(local.row) & '</option>'/>
				</cfloop>
			</cfif>

		</cfif>

		<cfreturn '<select name="#local.fieldName#" id="#arguments.id#"#arguments.extra#>' & local.options & '</select>'/>
	</cffunction>

</cfcomponent>