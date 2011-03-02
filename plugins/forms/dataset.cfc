<cfcomponent name="Dataset" output="no" hint="Abstracts a data set for use in validating and displaying form fields.">
	<cffunction name="init" output="no">
		<cfargument name="data"            required="yes"/>
		<cfargument name="idField"         default="id"/>
		<cfargument name="labelField"      default="label"/>
		<cfargument name="groupIdField"    default=""/>
		<cfargument name="groupLabelField" default=""/>

		<cfset variables.data = arguments.data/>
		<cfset variables.idField = arguments.idField/>
		<cfset variables.labelField = arguments.labelField/>
		<cfset variables.groupIdField = arguments.groupIdField/>
		<cfset variables.groupLabelField = arguments.groupLabelField/>

		<cfset Rewind()/>

		<cfreturn this/>
	</cffunction>

	<cffunction name="rewind" output="no">
		<cfset variables.currentRow = 1/>
	</cffunction>

	<cffunction name="next" output="no">
		<cfset ++variables.currentRow/>
	</cffunction>

	<cffunction name="getData" output="no">
		<cfreturn variables.data/>
	</cffunction>

	<cffunction name="hasGroup" output="no">
		<cfreturn Len(variables.groupIdField) gt 0/>
	</cffunction>

</cfcomponent>