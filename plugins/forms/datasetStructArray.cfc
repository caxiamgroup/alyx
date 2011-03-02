<cfcomponent name="DatasetStructArray" extends="dataset" output="no">

	<cffunction name="getCount" output="no">
		<cfreturn ArrayLen(variables.data)/>
	</cffunction>

	<cffunction name="getId" output="no">
		<cfargument name="row" default="#variables.currentRow#"/>
		<cfreturn variables.data[arguments.row][variables.idField]/>
	</cffunction>

	<cffunction name="getLabel" output="no">
		<cfargument name="row" default="#variables.currentRow#"/>
		<cfreturn variables.data[arguments.row][variables.labelField]/>
	</cffunction>

</cfcomponent>